//
//  ReviewListViewController.swift
//  CustomKeyboard
//

import UIKit

final class ReviewListViewController: BaseViewController {

    // MARK: - Properties

    private let reviewListView = ReviewListView()

    // MARK: - Lifecycle

    override func loadView() {
        self.view = reviewListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reviewListView.uploadButton.addTarget(
            self,
            action: #selector(uploadButtonTouched(_:)),
            for: .touchUpInside
        )
    }

    override func setupView() {
        setTableViewDelegate()
    }
    
    @objc func uploadButtonTouched(_ sender: UIButton) {
        let keyboardViewController = KeyboardViewController()
        keyboardViewController.modalPresentationStyle = .fullScreen
        present(keyboardViewController, animated: true)
    }
}

// MARK: - View setting methods

extension ReviewListViewController {

    private func setTableViewDelegate() {
        reviewListView.reviewTableView.dataSource = self
    }

}

// MARK: - UITableViewDataSource

extension ReviewListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ReviewTableViewCell.identifier,
            for: indexPath
        ) as? ReviewTableViewCell
        else {
            return UITableViewCell()
        }

        return cell
    }

}
