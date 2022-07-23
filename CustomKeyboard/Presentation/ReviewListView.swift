//
//  ReviewListView.swift
//  CustomKeyboard
//
//  Created by 이윤주 on 2022/07/13.
//

import UIKit

final class ReviewListView: UIView {

    // MARK: - UIProperties

    private lazy var reviewWritingView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.tintColor = .systemGray4
        imageView.image = Style.profileImage
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var reviewWritingLabel: BasePaddingLabel = {
        let label = BasePaddingLabel()
        label.backgroundColor = .systemGray6
        label.textColor = .systemGray
        label.text = Text.reviewWritingPlaceHolder
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = Style.reviewLineLimit
        label.layer.cornerRadius = Style.cornerRadius
        label.clipsToBounds = true
        return label
    }()

    lazy var uploadButton: UIButton = {
        let button = UIButton()
        guard let descriptor = UIFontDescriptor.preferredFontDescriptor(
            withTextStyle: .callout
        ).withSymbolicTraits(.traitBold) else {
            return button
        }
        button.backgroundColor = .systemPink
        button.setTitle(Text.uploadButtonTitle, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(descriptor: descriptor, size: .zero)
        button.layer.cornerRadius = Style.cornerRadius
        return button
    }()

    lazy var reviewTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            ReviewTableViewCell.self,
            forCellReuseIdentifier: ReviewTableViewCell.identifier
        )
        tableView.separatorInset.left = Style.padding
        tableView.separatorInset.right = Style.padding
        return tableView
    }()

    // MARK: - Lifecycles

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    @available(*, unavailable, message: "This initializer is not available.")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }

    override func layoutSubviews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height * Style.half
    }

}

// MARK: - View setting methods

extension ReviewListView {

    private func setupView() {
        [profileImageView, reviewWritingLabel, uploadButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            reviewWritingView.addSubview($0)
        }

        [reviewWritingView, reviewTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }

    private func setupConstraints() {
        setupConstraintsOfReviewWritingView()
        setupConstraintsOfProfileImageView()
        setupConstraintsOfReviewWritingLabel()
        setupConstraintsOfUploadButton()
        setupConstraintsOfTableView()
    }

    private func setupConstraintsOfReviewWritingView() {
        NSLayoutConstraint.activate([
            reviewWritingView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: Style.padding),
            reviewWritingView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            reviewWritingView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            reviewWritingView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            reviewWritingView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * Style.reviewWritingViewHeightRatio)
        ])
    }

    private func setupConstraintsOfProfileImageView() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: reviewWritingView.safeAreaLayoutGuide.leadingAnchor, constant: Style.padding),
            profileImageView.topAnchor.constraint(equalTo: reviewWritingView.safeAreaLayoutGuide.topAnchor, constant: Style.padding),
            profileImageView.widthAnchor.constraint(equalTo: reviewWritingView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.15),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.safeAreaLayoutGuide.widthAnchor)
        ])
    }

    private func setupConstraintsOfReviewWritingLabel() {
        NSLayoutConstraint.activate([
            reviewWritingLabel.leadingAnchor.constraint(equalTo: profileImageView.safeAreaLayoutGuide.trailingAnchor, constant: Style.spacing),
            reviewWritingLabel.centerYAnchor.constraint(equalTo: profileImageView.safeAreaLayoutGuide.centerYAnchor),
            reviewWritingLabel.heightAnchor.constraint(equalTo: profileImageView.safeAreaLayoutGuide.widthAnchor, multiplier: Style.reviewWritingLabelHeightRatio)
        ])
    }

    private func setupConstraintsOfUploadButton() {
        NSLayoutConstraint.activate([
            uploadButton.leadingAnchor.constraint(equalTo: reviewWritingLabel.safeAreaLayoutGuide.trailingAnchor, constant: Style.spacing),
            uploadButton.trailingAnchor.constraint(equalTo: reviewWritingView.safeAreaLayoutGuide.trailingAnchor, constant: -Style.spacing),
            uploadButton.centerYAnchor.constraint(equalTo: profileImageView.safeAreaLayoutGuide.centerYAnchor),
            uploadButton.widthAnchor.constraint(equalTo: profileImageView.safeAreaLayoutGuide.widthAnchor),
            uploadButton.heightAnchor.constraint(equalTo: profileImageView.safeAreaLayoutGuide.heightAnchor, multiplier: Style.uploadButtonHeightRatio)
        ])
    }

    private func setupConstraintsOfTableView() {
        NSLayoutConstraint.activate([
            reviewTableView.topAnchor.constraint(equalTo: reviewWritingView.safeAreaLayoutGuide.bottomAnchor),
            reviewTableView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            reviewTableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            reviewTableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

// MARK: - NameSpaces

extension ReviewListView {

    private enum Text {
        static let reviewWritingPlaceHolder: String = "이 테마가 마음에 드시나요?"
        static let uploadButtonTitle: String = "작성"
    }

    private enum Style {
        static let profileImage: UIImage? = UIImage(systemName: "person.fill")
        static let reviewLineLimit: Int = 1
        static let spacing: CGFloat = 10
        static let padding: CGFloat = 15
        static let half: CGFloat = 0.5
        static let cornerRadius: CGFloat = 20
        static let reviewWritingViewHeightRatio: CGFloat = 0.3
        static let profileImageWidthRatio: CGFloat = 0.15
        static let reviewWritingLabelHeightRatio: CGFloat = 0.8
        static let uploadButtonHeightRatio: CGFloat = 0.8
    }

}
