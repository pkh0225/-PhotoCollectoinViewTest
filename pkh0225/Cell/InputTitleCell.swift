//
//  InputPriceCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class InputTitleCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static var itemCount: Int = 1

    @IBOutlet weak var textField: UITextField!

    var actionClosure: ActionClosure?

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    static func getSize(_ data: Any?, width: CGFloat) -> CGSize {
        return CGSize(width: width, height: fromNibSize().h)
    }

    func configure(_ data: Any?) {

    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {

    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        actionClosure?(#function, textField.text)

    }
}

