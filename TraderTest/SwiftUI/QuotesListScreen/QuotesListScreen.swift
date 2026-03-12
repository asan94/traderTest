//
//  QuotesListScreen.swift
//  TraderTest
//
//  Created by Asan Ametov on 10.03.2026.
//

import SwiftUI

struct QuotesListScreen: View {
    @StateObject var viewModel: QuotesScreenViewModel
    @State private var showError = false

    var body: some View {
        ZStack {
            QuotesListContent()
                .environmentObject(viewModel.store)
                .onAppear {
                    viewModel.connectSocket()
                }
                .onDisappear {
                    viewModel.disconnectSocket()
                }
                .refreshable {
                    viewModel.refresh()
                }
            if viewModel.isLoading && viewModel.store.rows.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            showError = !newValue.isEmpty
        }
        .alert(Constants.error, isPresented: $showError) {
            if viewModel.needReload {
                Button(Constants.reload) {
                    viewModel.fetchData()
                }
  
            }
            if viewModel.useDefaultTickers {
                Button(Constants.useDefaultsTickers) {
                    viewModel.loadFromDefaultTickers()
                }
            }
            Button(Constants.close, role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .task {
            viewModel.fetchData()
        }
    }

}

struct QuotesListContent: View {
    @EnvironmentObject var store: QuotesStore

    var body: some View {
        List {
            ForEach(store.rows) { row in
                if let name = row.name {
                    QuotesRowView(
                        ticker: row.ticker,
                        name: name,
                        iconURL: row.iconURL,
                        live: store.live(for: row.ticker)
                    )
                }
            }
        }
        .listStyle(.plain)
    }
}
