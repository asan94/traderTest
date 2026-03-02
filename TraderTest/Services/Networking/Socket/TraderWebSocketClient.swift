//
//  TraderWebSocketClient.swift
//  TraderTest
//
//  Created by Asan Ametov on 27.02.2026.
//

import Foundation

protocol TraderWebSocketClientDelegate: AnyObject {
    func didConnect()
    func didReceiveQuotes(_ quotes: QuoteDM)
    func didDisconnect(reason: String?)
    func didError(_ error: String)
}

protocol TraderWebSocketClientProtocol {
    func connect()
    func disconnect()
    func subscribeQuotes(tickers: [String])
    var delegate: TraderWebSocketClientDelegate? { get set }
}
final class TraderWebSocketClient: NSObject, TraderWebSocketClientProtocol {
    
    private var task: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    weak var delegate: TraderWebSocketClientDelegate?

    private var isConnected = false
    private var reconnectTimer: Timer?
    private var pingTimer: Timer?
    private let tradnetURL = "wss://wss.tradernet.com/"
    
    private var _isLoggingEnabled: Bool = false
    
    var isLoggingEnabled: Bool {
        get { _isLoggingEnabled }
        set {
            #if DEBUG
            _isLoggingEnabled = newValue
            #endif
        }
    }
    
    override init() {
        super.init()
        guard let url = URL(string: tradnetURL) else {
            return
        }
        task = session.webSocketTask(with: url)
        task?.delegate = self
    }
    
    func connect() {
        guard !isConnected else { return }
        printLog("Websocket connecting...")
        task?.resume()
        receiveLoop()
        startPing()
    }
    
    func disconnect() {
        stopPing()
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        isConnected = false
        delegate?.didDisconnect(reason: "Manual disconnect")
    }
    
    func subscribeQuotes(tickers: [String]) {
        guard isConnected else {
            printLog("⚠️ Connect first!")
            return
        }
        let message: [Any] = ["quotes", tickers]
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        printLog("📤 Subscribe: \(jsonString)")
        task?.send(.string(jsonString)) { [weak self] error in
            if let error {
                self?.printLog("❌ Send error:", error)
            }
        }
    }
    
    func subscribeQuotes() {
        guard isConnected else {
            return
        }
        task?.send(.string("quotes")) { [weak self] error in
            if let error {
                self?.printLog("❌ Send error:", error)
            }
        }
            
    }
    private func startPing() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func stopPing() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func sendPing() {
        task?.sendPing { [weak self] error in
            if let error {
                self?.printLog("❌ Ping error:", error)
            }
        }
    }
    
    private func receiveLoop() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                printLog("❌ Receive error:", error)
                self.delegate?.didError(error.localizedDescription)
                self.handleDisconnect()
                
            case .success(let message):
                self.handleMessage(message)
                self.receiveLoop()  // Рекурсия!
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            printLog("📥 Raw: \(text)")
            guard let data = text.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [Any],
                  json.count > 1, let event = json[0] as? String else { return }
            
            switch event {
            case "q":
                if let quotesDic = json[1] as? [String: Any], let quote = try? QuoteDM(quotesDic) {
                    delegate?.didReceiveQuotes(quote)
                }
            default:
                printLog("Event:", event, json[1])
            }
            
        case .data(let data):
            printLog("Binary data: \(data.count) bytes")
        @unknown default:
            break
        }
    }
    
    private func handleDisconnect() {
        isConnected = false
        stopPing()
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.printLog("🔄 Reconnecting...")
            self?.connect()
        }
    }
    
    func printLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        if _isLoggingEnabled {
            print(items)
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension TraderWebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
        printLog("✅ TraderWebSocket Connected! Protocol: ")
        isConnected = true
        delegate?.didConnect()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        printLog("🔌 TraderWebSocket Closed: \(closeCode)")
        handleDisconnect()
    }
}
