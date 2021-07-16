//
//  TitleBarViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

protocol TitleBarViewControllerDelegate: AnyObject {
    func onBackButton()
    func onSubmitButton()
}

extension TitleBarViewControllerDelegate {
    func onBackButton() {}
    func onSubmitButton() {}
}

class TitleBarViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    weak var delegate: TitleBarViewControllerDelegate?

    var isBackButton: Bool = false {
        didSet {
            backButton.isHidden = !isBackButton
        }
    }
    var isSubmitButton: Bool = false {
        didSet {
            submitButton.isHidden = !isSubmitButton
        }
    }
    var titleString: String = "" {
        didSet {
            titleLabel.text = titleString
        }
    }
    var submitTitle: String = "" {
        didSet {
            submitButton.setTitle(submitTitle, for: .normal)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.isHidden = !isBackButton
        submitButton.isHidden = !isSubmitButton
        titleLabel.text = titleString
    }

    @IBAction func onBackButton(_ sender: UIButton) {
        delegate?.onBackButton()
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onSubmitButton(_ sender: UIButton) {
        delegate?.onSubmitButton()
    }
}
