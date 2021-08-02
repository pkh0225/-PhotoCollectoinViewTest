//
//  InputDescriptionCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class InputDescriptionCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static var itemCount: Int = 1

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!

    var actionClosure: ActionClosure?
    var data: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        textView.autocapitalizationType = .none
    }

    static func getSize(_ data: Any?, width: CGFloat) -> CGSize {
        return CGSize(width: width, height: fromXibSize().h)
    }

    func configure(_ data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? String, data.isValid else { return }
        self.data = data
        if self.textView.text != data {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.textView.becomeFirstResponder()
            }
        }
        self.textView.text = data
        placeholderLabel.isHidden = true
    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {

    }


}

extension InputDescriptionCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, text.isValid {
            placeholderLabel.isHidden = true
        }
        else {
            placeholderLabel.isHidden = false
        }

        actionClosure?(#function, textView.text)
    }
}
