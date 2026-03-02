//
//  QuotesListTableView.swift
//  TraderTest
//
//  Created by Asan Ametov on 28.02.2026.
//

import UIKit
import SnapKit

class QuotesListTableViewCell: UITableViewCell {

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = UIColor.secondarySystemBackground
        imageView.isHidden = true
        return imageView
    }()

    private let tickerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let exchangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()

    private let changePointsLabel: UILabel = {
        let label = PaddingLabel()
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .right
        label.paddingLeft = 4
        label.paddingRight = 4
        label.paddingTop = 2
        label.paddingBottom = 2
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()

    private var tickerLeadingToSuperview: Constraint!
//    private var tickerLeadingToFlag: Constraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        buildUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildUI() {
        tickerLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let rightStack = UIStackView(arrangedSubviews: [changePointsLabel, priceLabel])
        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .trailing
        rightStack.contentHuggingPriority(for: .horizontal)
        
        contentView.addSubview(logoImageView)
        contentView.addSubview(tickerLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(rightStack)
        logoImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.top.equalTo(contentView.snp.top).offset(16)
            make.size.equalTo(24)
        }
        tickerLabel.snp.makeConstraints { make in
            tickerLeadingToSuperview = make.leading.equalTo(contentView.snp.leading).offset(44).constraint
            make.top.equalTo(contentView.snp.top).offset(16)
            make.trailing.lessThanOrEqualTo(rightStack.snp.leading).offset(-8)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.top.greaterThanOrEqualTo(tickerLabel.snp.bottom).offset(8)
            make.trailing.lessThanOrEqualTo(rightStack.snp.leading).offset(-8)
            make.bottom.equalTo(contentView.snp.bottom).offset(-16)
        }
        
        rightStack.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.safeAreaLayoutGuide.snp.trailing).offset(-8)
            make.top.greaterThanOrEqualTo(contentView.snp.top).offset(16)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(45)
            make.width.greaterThanOrEqualTo(110)
        }
    }

    func configure(_ vm: QuoteCellViewModel) {
        tickerLabel.text = vm.tickerText
        nameLabel.text = vm.name
        exchangeLabel.text = vm.exchange
        changePointsLabel.text = vm.changePercentText
        priceLabel.text = vm.priceText
        let valueColor: UIColor = vm.isPositive ? AppColors.up : (vm.isNegative ? AppColors.down : AppColors.neutral)
        changePointsLabel.textColor = valueColor
        switch vm.highlight {
        case .none:
            self.changePointsLabel.backgroundColor = .clear
        case .up:
            self.changePointsLabel.textColor = .white
            self.changePointsLabel.backgroundColor = AppColors.highlightUp
        case .down:
            self.changePointsLabel.textColor = .white
            self.changePointsLabel.backgroundColor = AppColors.highlightDown
        }

        if let url = vm.iconURL {
            ImageLoader.shared.load(urlString: url) { [weak self] image, error in
                if error != nil || image == nil {
                    self?.tickerLeadingToSuperview.update(offset: 16)
                    self?.logoImageView.isHidden = true
                } else  if let image = image {
                    if image.size.width > 5 {
                        self?.tickerLeadingToSuperview.update(offset: 46)
                    } else {
                        self?.tickerLeadingToSuperview.update(offset: 16)
                    }
                    self?.logoImageView.isHidden = false
                    self?.logoImageView.image = image
                }
            }
        }
    }

    private func flash(background: UIColor, defaultColor: UIColor) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction]) {
            self.changePointsLabel.textColor = .white
            self.changePointsLabel.backgroundColor = background
        }
    }

}
