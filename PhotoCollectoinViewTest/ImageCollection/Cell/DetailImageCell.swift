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

    private var checkZoom1: Bool = false
    private var checkZoom2: Bool = false
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
        imageView.setUrlImage(data.urls?.regular, placeHolderImage: data.urls?.tempImage, backgroundColor: .black)
        data.urls?.tempImage = nil
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
            checkZoom2 = true
            imageView.setUrlImage(data?.urls?.raw, placeHolderImage: imageView.image, backgroundColor: .black, transitionAnimation: false)
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

    func scrollViewDidZoom(_ scrollView: UIScrollView) {

        if scrollView.zoomScale > 1, checkZoom1 == false {
            checkZoom1 = true
            imageView.setUrlImage(data?.urls?.full, placeHolderImage: imageView.image, backgroundColor: .black, transitionAnimation: false)
        }
        else if scrollView.zoomScale > 3, checkZoom2 == false {
            checkZoom2 = true
            imageView.setUrlImage(data?.urls?.raw, placeHolderImage: imageView.image, backgroundColor: .black, transitionAnimation: false)
        }
    }
}
