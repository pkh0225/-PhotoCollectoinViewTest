//
//  SelectLabelCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

protocol CategoryCellProtocol {
    var title: String { get }
    var isSelected: Bool { get }
}
class CategoryCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static var itemCount: Int = 1

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!

    var actionClosure: ActionClosure?
    var data: CategoryCellProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func getSize(_ data: Any?, width: CGFloat) -> CGSize {
        return CGSize(width: width, height: fromXibSize().h)
    }

    func configure(_ data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? CategoryCellProtocol else { return }
        self.data = data

        titleLabel.text = data.title
        if data.isSelected {
            titleLabel.textColor = .orange
            checkLabel.isHidden = false
        }
        else {
            titleLabel.textColor = .black
            checkLabel.isHidden = true
        }
    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {
        actionClosure?(#function, data)
    }

}
