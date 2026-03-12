//
//  QuotesListView.swift
//  TraderTest
//
//  Created by Asan Ametov on 28.02.2026.
//

import UIKit
import SnapKit

protocol QuotesListViewProtocol: AnyObject {
    var tableView: UITableView { get }
    func showLoadder(isShow: Bool)
    func showError(message: String)
}

class QuotesListView: UIView, QuotesListViewProtocol {

    lazy var tableView:UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(table)
        table.separatorStyle = .singleLine
        table.rowHeight = UITableView.automaticDimension
        table.backgroundColor = .white
        table.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: 100, height: 0.01))
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        table.register(QuotesListTableViewCell.self)
        table.refreshControl = refreshControll
        table.snp.makeConstraints { make in
            make.left.right.equalTo(self)
            make.top.bottom.equalTo(self)
        }
        return table
    }()

    lazy var refreshControll: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        return refreshControl
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return activityIndicator
    }()
    
    func showLoadder(isShow: Bool) {
        isShow ? activityIndicator.startAnimating(): activityIndicator.stopAnimating()
    }
    
    func showError(message: String) {
        
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        bringSubviewToFront(activityIndicator)
    }
}
