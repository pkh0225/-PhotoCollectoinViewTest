//
//  DetailImageCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/16.
//

import UIKit

class DetailImageCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static let SELECTED_ADD_KEY: String = "SELECTED_ADD_KEY"
    static let SELECTED_REMOVE_KEY: String = "SELECTED_REMOVE_KEY"
    static var itemCount: Int = 1

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!


    var imageView = UIImageView()
    var actionClosure: ActionClosure?
    var data: UnslpashImageModel?


    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        setTapGesture()
    }

    func configure(_ data: Any?) {
        guard let data = data as? UnslpashImageModel else { return }
        self.data = data
        scrollView.zoomScale = 1.0
        nameLabel.text = data.user?.username
        // 고해상도 이미지를 불러오기 전에 미리 보여주기 윈한 임시 이미지.
        if let tempImage = data.urls?.tempImage {
            imageView.image = tempImage
            data.urls?.tempImage = nil
        }
        imageView.setUrlImage(data.urls?.regular, backgroundColor: .black)
        selectedButton.isSelected = data.isSeleected
        if data.selectedCount > 0 {
            countLabel.text = "\(data.selectedCount)"
            countLabel.isHidden = false
        }
        else {
            countLabel.isHidden = true
        }
    }


    func setTapGesture() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    @objc func handleDoubleTap(_ gestureRecognizer: UIGestureRecognizer?) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
        else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    @IBAction func onSelectedButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        data?.isSeleected = sender.isSelected
        let key = sender.isSelected ? Self.SELECTED_ADD_KEY : Self.SELECTED_REMOVE_KEY
        actionClosure?(key, data)
    }
}

extension DetailImageCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
