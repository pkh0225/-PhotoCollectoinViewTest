//
//  InputPriceCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class InputPriceCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static let PRICE_KEY: String = "PRICE_KEY"
    static let SUGGEST_KEY: String = "SUGGEST_KEY"
    static var itemCount: Int = 1

    @IBOutlet weak var wonLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var suggestionButton: UIButton!
    @IBOutlet weak var freeButton: UIButton!

    var actionClosure: ActionClosure?
    var data: PriceModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.autocapitalizationType = .none
    }

    static func getSize(_ data: Any?, width: CGFloat) -> CGSize {
        return CGSize(width: width, height: fromXibSize().h)
    }

    func configure(_ data: Any?) {
        guard let data = data as? PriceModel else { return }
        self.data = data
    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {
    }

    func updateUI() {
        if let text = textField.text, text.isValid {
            wonLabel.textColor = UIColor.black
            if text != "0" {
                suggestionButton.isEnabled = true
                textField.text = textField.text?.convertPriceFormat()
            }
        }
        else {
            wonLabel.textColor = UIColor.systemGray3
            suggestionButton.isEnabled = false
            suggestionButton.isSelected = false
        }
    }

    func showFreeButton(_ show: Bool) {
        if show {
            freeButton.isHidden = false
            freeButton.centerYConstraint = self.h
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.2) {
                self.freeButton.centerYConstraint = self.freeButton.centerYDefaultConstraint
                self.wonLabel.centerYConstraint = -self.h
                self.textField.centerYConstraint = -self.h
                self.layoutIfNeeded()
            }
            completion: { _ in
                self.textField.text = nil
                self.updateUI()
            }
        }
        else {
            UIView.animate(withDuration: 0.2) {
                self.freeButton.centerYConstraint = self.h
                self.wonLabel.centerYConstraint = self.wonLabel.centerYDefaultConstraint
                self.textField.centerYConstraint = self.textField.centerYDefaultConstraint
                self.layoutIfNeeded()
            }
            completion: { _ in
                self.freeButton.isHidden = true
            }
        }
    }

    @IBAction func onSuggestionButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        data?.isSuggestion = sender.isSelected
        actionClosure?(Self.SUGGEST_KEY, data)
    }

    @IBAction func onFreeButton(_ sender: UIButton) {
        showFreeButton(false)
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if let text = textField.text, text.isValid {
            data?.price = text.replace(",", "").toInt()
        }
        else {
            data?.price = -1
        }
        updateUI()
        actionClosure?(Self.PRICE_KEY, data)
    }
}

extension InputPriceCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }

        if text == "0" {
            showFreeButton(true)
        }
    }
}
