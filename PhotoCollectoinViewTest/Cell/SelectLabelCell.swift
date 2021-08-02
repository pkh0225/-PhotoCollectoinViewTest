//
//  SelectLabelCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit
struct SelectLabelCellModel {
    var title: String = ""
}

class SelectLabelCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static var itemCount: Int = 1

    @IBOutlet weak var titleLabel: UILabel!

    var actionClosure: ActionClosure?
    var data: SelectLabelCellModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func getSize(_ data: Any? = nil, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: fromXibSize().h)
    }

    func configure(_ data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? SelectLabelCellModel else { return }
        self.data = data

        titleLabel.text = data.title
    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {
        actionClosure?(#function, data)
    }

}
