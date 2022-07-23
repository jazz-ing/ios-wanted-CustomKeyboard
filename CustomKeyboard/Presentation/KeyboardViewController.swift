//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by BH on 2022/07/12.
//

import UIKit

class KeyboardViewController: BaseViewController {

    var keyboardView: KeyboardView!
    
    override func loadView() {
        super.loadView()
        keyboardView = .init(frame: self.view.frame)
        self.view = keyboardView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardView.returnKeyButton.addTarget(
            self,
            action: #selector(returnKeyButtonTouched(_:)),
            for: .touchUpInside
        )
    }
    
    @objc func returnKeyButtonTouched(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
