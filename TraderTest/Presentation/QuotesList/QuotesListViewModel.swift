//
//  QuotesListCellViewModel.swift
//  TraderTest
//
//  Created by Asan Ametov on 28.02.2026.
//

import UIKit

final class QuotesListViewModel: TraderWebSocketClientDelegate {
    
    struct State: Equatable {
        var items: [QuoteCellViewModel] = []
        var isLoading: Bool = false
        var errorText: String? = nil
    }
    
    private let api: TraderAPIProtocol
    private var socketManager: TraderWebSocketClientProtocol
    private(set) var state = State() {
        didSet { onStateChange?(state) }
    }
    
    var onStateChange: ((State) -> Void)?
    var items: Set<QuoteDM> = []
    private var tickers: [String] = []
    
    init(api: TraderAPIProtocol, socketManager: TraderWebSocketClientProtocol) {
        self.api = api
        self.socketManager = socketManager
        self.socketManager.delegate = self
    }
    
    func connectSocket() {
        self.socketManager.connect()
    }
   
    func disconnectSocket() {
        self.socketManager.disconnect()
    }
    
    func fetchData() {
        state.isLoading = true
        state.errorText = nil
        
        api.getTopQuotes(type: "stocks", exchange: "russia", gainers: 0, limit: 30) { [weak self] result in
            switch result {
            case .success(let tickers):
                self?.tickers = tickers.tickers
                self?.subscribeTickers()
            case .failure(let error):
                if let tickerData = NSDataAsset(.tickers)?.data, let tickers = tickerData.jsonDecode(typeOf: TickersDM.self) {
                    self?.tickers = tickers.tickers
                    self?.subscribeTickers()
                }
            }
        }
    }
    
    func refresh() {
        fetchData()
    }
    
    func subscribeTickers() {
        self.socketManager.subscribeQuotes(tickers: tickers)
    }
    
    func didConnect() {
        self.socketManager.subscribeQuotes(tickers: self.tickers)
    }
    
    func didReceiveQuotes(_ quotes: QuoteDM) {
        let lastQuotes = items.first(where: { $0.ticker == quotes.ticker })
        if let lastQuotes {
            items.update(with: quotes.diff(from: lastQuotes))
        } else {
            items.update(with:quotes)
        }
        
        let newViewModels: [QuoteCellViewModel] = items.map { quoteDM in
            var highlight: QuoteCellViewModel.Highlight = .none
            
            if quotes.ticker == lastQuotes?.ticker, let lastChange = lastQuotes?.change, let change = quotes.change {
                if lastChange == change {
                    highlight = .none
                } else {
                    highlight = lastChange < change ? .up: .down
                }
            } else if let hasChanges = quoteDM.hasChanges, hasChanges, let change = quoteDM.change, change != 0 {
                highlight = change > 0 ? .up: .down
            }
            return QuoteCellViewModel(quote: quoteDM, highlight: highlight)
        }
        DispatchQueue.main.async {
            self.state = .init(items: newViewModels, isLoading: false, errorText: nil)
        }
    }
    
    func didDisconnect(reason: String?) {
        
    }
    
    func didError(_ error: String) {
        self.state = .init(items: state.items, isLoading: false, errorText: error)
    }
}

