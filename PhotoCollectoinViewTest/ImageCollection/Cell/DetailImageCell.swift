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

    private var checkZoom: Bool = false
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
            let point = gestureRecognizer?.location(in: scrollView) ?? .zero
            let scale: CGFloat = 200
            scrollView.zoom(to: CGRect(x: point.x - (scale / 2), y: point.y - (scale / 2), width: scale, height: scale), animated: true)
            if checkZoom == false {
            checkZoom = true
            imageView.setUrlImage(data?.urls?.raw, placeHolderImage: imageView.image, backgroundColor: .black, transitionAnimation: false)
            }
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

        if scrollView.zoomScale > 1, checkZoom == false {
            checkZoom = true
            imageView.setUrlImage(data?.urls?.raw, placeHolderImage: imageView.image, backgroundColor: .black, transitionAnimation: false)
        }
    }
}
