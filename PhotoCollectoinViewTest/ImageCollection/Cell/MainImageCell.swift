//
//  MainImageCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/16.
//

import UIKit

struct ImageAnimationInfo {
    var index: Int = 0
    var image: UIImage?
}

class MainImageCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static let CLICK_KEY: String = "CLICK_KEY"
    static let SELECTED_ADD_KEY: String = "SELECTED_ADD_KEY"
    static let SELECTED_REMOVE_KEY: String = "SELECTED_REMOVE_KEY"

    static var itemCount: Int  = 2

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!

    var actionClosure: ActionClosure? = nil
    var data: UnslpashImageModel?

    static func getSize(_ data: Any? = nil, width: CGFloat) -> CGSize {
        return CGSize(width: width, height: width)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func configure(_ data: Any?) {
        guard let data = data as? UnslpashImageModel else { return }
        self.data = data
        nameLabel.text = "\(data.user?.username ?? "")"
        imageView.setUrlImage(data.urls?.thumb, backgroundColor: UIColor(hexString: data.color))
        selectedButton.isSelected = data.isSeleected
        if data.selectedCount > 0 {
            countLabel.text = "\(data.selectedCount)"
            countLabel.isHidden = false
        }
        else {
            countLabel.isHidden = true
        }
    }


    @IBAction func onClick(_ sender: UIButton) {
        let info = ImageAnimationInfo(index: indexPath.row, image: imageView.image)
        actionClosure?(Self.CLICK_KEY, info)
    }

    @IBAction func onSelectedbutton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        data?.isSeleected = sender.isSelected
        let key = sender.isSelected ? Self.SELECTED_ADD_KEY : Self.SELECTED_REMOVE_KEY
        actionClosure?(key, data)
    }

    func getImageWindowsRect() -> CGRect {
        let rect = imageView.superview?.convert(imageView.frame, to: nil) ?? .zero
        return rect
    }
}

