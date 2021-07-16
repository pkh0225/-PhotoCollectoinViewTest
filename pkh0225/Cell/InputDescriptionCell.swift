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
    var data: SelectLabelCellModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func getSize(_ data: Any?, width: CGFloat) -> CGSize {
        return CGSize(width: width, height: fromNibSize().h)
    }

    func configure(_ data: Any?) {
        guard let data = data as? SelectLabelCellModel else { return }
        self.data = data

    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {
        print("title: \(data?.title ?? "")")

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
