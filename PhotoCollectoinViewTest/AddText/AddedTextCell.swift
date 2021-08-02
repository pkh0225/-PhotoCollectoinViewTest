//
//  AddedTextCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/19.
//

import UIKit

class AddedTextCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static let SELECT_KEY: String = "SELECT_KEY"
    static let REMOVE_KEY: String = "REMOVE_KEY"
    static var itemCount: Int = 1

    @IBOutlet weak var textLabel: UILabel!
    var actionClosure: ActionClosure?
    var data: String?

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    static func getSize(_ data: Any?, width: CGFloat) -> CGSize {
        guard let data = data as? String else { return .zero }
        let cell = self.fromXib(cache: true)
        var height = cell.h - cell.textLabel.h
        height += data.height(maxWidth: cell.w - (cell.w - cell.textLabel.w), font: cell.textLabel.font)
        return CGSize(width: width, height: height)
    }

    func configure(_ data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? String else { return }
        self.data = data
        textLabel.text = data
    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {
        actionClosure?(Self.SELECT_KEY, data)
    }


    @IBAction func onRemoveButton(_ sender: UIButton) {
        actionClosure?(Self.REMOVE_KEY, indexPath.row)
    }
}
