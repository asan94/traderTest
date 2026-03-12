//
//  QuotesScreenViewModel.swift
//  TraderTest
//
//  Created by Asan Ametov on 11.03.2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class QuotesScreenViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String = ""
    @Published var needReload = false
    @Published var useDefaultTickers = false

    private weak var router: QuotesRoutingLogic?
    private let api: TraderAPIProtocol
    private var socketManager: TraderWebSocketClientProtocol
    var store = QuotesStore()
    
    private var cacheByTicker: [String: QuoteDM] = [:]
    private var tickers: [String] = []
    var items: Set<QuoteDM> = []

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
        isLoading = true
        errorMessage = ""
        Task {
            let tickers = await api.getTopQuotes(type: Constants.quoteType, exchange: Constants.quoteExchange, gainers: Constants.quoteGainers, limit: Constants.quoteLimit)
            switch tickers {
            case .success(let tickers):
                self.isLoading = false
                self.tickers = tickers.tickers
                let rows: [QuotesStore.Row] = tickers.tickers.map { QuotesStore.Row(ticker: $0, name: nil, iconURL: nil) }
                self.store.setRows(rows.map { .init(ticker: $0.ticker, name: $0.name, iconURL: $0.iconURL) })
                self.subscribeTickers()
            case .failure:
                isLoading = false
                needReload = true
                useDefaultTickers = true
                errorMessage = Constants.errorFetchingQuotes
            }
        }
    }
    
    func loadFromDefaultTickers() {
        isLoading = true
        errorMessage = ""
        if let tickerData = NSDataAsset(.tickers)?.data, let tickers = tickerData.jsonDecode(typeOf: TickersDM.self) {
            self.tickers = tickers.tickers
            self.tickers = tickers.tickers
            let rows: [QuotesStore.Row] = tickers.tickers.map { QuotesStore.Row(ticker: $0, name: nil, iconURL: nil) }
            self.store.setRows(rows.map { .init(ticker: $0.ticker, name: $0.name, iconURL: $0.iconURL) })
            self.subscribeTickers()
        }
    }
    
    func refresh() {
        fetchData()
    }
    
    func subscribeTickers() {
        self.socketManager.subscribeQuotes(tickers: tickers)
    }
    
    func didSelect(ticker: String) {
        if let quotDM = items.first(where: { $0.ticker == ticker }) {
            router?.openDetails(quotDM: quotDM)
        }
    }
}

extension QuotesScreenViewModel: TraderWebSocketClientDelegate {
    
    func didConnect() {
        self.socketManager.subscribeQuotes(tickers: self.tickers)
    }
    
    func didDisconnect(reason: String?) {
        if let reason {
            needReload = true
            errorMessage = reason
        }
    }
    
    func didReceiveQuotes(_ quotes: QuoteDM) {
        let old = cacheByTicker[quotes.ticker]
        let merged = old.map{ quotes.diff(from:$0) } ?? quotes
        cacheByTicker[quotes.ticker] = merged
        Task { @MainActor in
            var highlight: QuoteLiveVM.Highlight = .none

            if quotes.ticker == old?.ticker, let lastChange = old?.change, let change = quotes.change {
                if lastChange == change {
                    highlight = .none
                } else {
                    highlight = lastChange < change ? .up: .down
                }
            } else if let hasChanges = quotes.hasChanges, hasChanges, let change = quotes.change, change != 0 {
                highlight = change > 0 ? .up: .down
            }
            store.updateStatic(ticker: merged.ticker, name: merged.name, iconURL: merged.iconURL)
            store.applyTick(ticker: merged.ticker, priceText: merged.priceText, changePercentText: merged.changePercentText, highlight:highlight, isPositive: merged.isPositive, isNegative: merged.isNegative)
        }
    }
    
    func didError(_ error: String) {
        errorMessage = error
    }
}
