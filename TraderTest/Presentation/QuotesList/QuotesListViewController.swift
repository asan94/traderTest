//
//  QuotesListViewController.swift
//  TraderTest
//
//  Created by Asan Ametov on 28.02.2026.
//

import UIKit

class QuotesListViewController: UIViewController {
    
    let viewModel: QuotesListViewModel
    
    private typealias DataSource = UITableViewDiffableDataSource<Int, QuoteCellViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, QuoteCellViewModel>
    private var dataSource: DataSource!
    private var currentItems: [QuoteCellViewModel] = []
    private let refreshControl = UIRefreshControl()

    init(viewModel: QuotesListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var theview: QuotesListViewProtocol {
        return view as! QuotesListViewProtocol
    }
    
    override func loadView() {
        super.loadView()
        self.view = QuotesListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupObservers()
        self.setupTableView()
        self.applySnapshot(with: [])
        self.fetchTickers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.connectSocket()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.disconnectSocket()
    }
    
    func fetchTickers() {
        self.viewModel.fetchData()
    }
    
    func setupObservers() {
        viewModel.onStateChange =  { [weak self] state in
            guard let self else { return }
            
            if currentItems.isEmpty {
                theview.showLoadder(isShow: state.isLoading)
            }
            
            if !state.isLoading, let refresh = self.theview.tableView.refreshControl, refresh.isRefreshing {
                refresh.endRefreshing()
            }
            
            if let err = state.errorText {
                self.showErorr(err)
            }
            
            if state.items.count > 0 {
                self.currentItems = state.items
                self.applySnapshot(with: state.items)
            }
        }
    }

    func setupTableView() {
        dataSource = makeDataSource()
        theview.tableView.dataSource = dataSource
        theview.tableView.refreshControl?.addTarget(self, action: #selector(onPullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc func onPullToRefresh(_ sender: UIRefreshControl) {
        self.viewModel.refresh()
    }
    
    private func makeDataSource() -> DataSource {
        DataSource(tableView: theview.tableView) { tableView, indexPath, vm in
            let cell = tableView.dequeueReusableCell(QuotesListTableViewCell.self, for: indexPath)
            cell.configure(vm)
            return cell
        }
    }
    
    private func applySnapshot(with quotes: [QuoteCellViewModel], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(quotes, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func showErorr(_ err: String) {
        let alert = UIAlertController(title: "Ошибка", message: err, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
