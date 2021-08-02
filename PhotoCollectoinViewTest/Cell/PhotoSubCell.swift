//
//  PhotoSubCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class PhotoSubCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static let IMAGE_CLICK_KEY: String = "IMAGE_CLICK_KEY"
    static let IMAGE_REMOVE_KEY: String = "IMAGE_REMOVE_KEY"
    static var itemCount: Int = 1

    @IBOutlet weak var imageView: UIImageView!

    var actionClosure: ActionClosure?
    var data: UnslpashImageModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func getSize(_ data: Any?, width: CGFloat) -> CGSize {
        return fromXibSize()
    }

    func configure(_ data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? UnslpashImageModel else { return }
        self.data = data
        imageView.setUrlImage(data.urls?.thumb)
    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {

    }

    @IBAction func onImageButton(_ sender: UIButton) {
        actionClosure?(Self.IMAGE_CLICK_KEY, (indexPath.row, imageView.image))
    }

    @IBAction func onRemoveButton(_ sender: UIButton) {
        actionClosure?(Self.IMAGE_REMOVE_KEY, indexPath.row)
    }

    func getImageWindowsRect() -> CGRect {
        let rect = imageView.superview?.convert(imageView.frame, to: nil) ?? .zero
        return rect
    }
}
