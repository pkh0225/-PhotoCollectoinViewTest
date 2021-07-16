//
//  PhotoCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class PhotoCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static var itemCount: Int = 1

    @IBOutlet weak var collectionView: UICollectionView!

    var actionClosure: ActionClosure?

    var selectedItems = [UnslpashImageModel]() {
        willSet {
            selectedItems.forEach { $0.selectedCount = 0 }
        }
        didSet {
            for (idx, data) in selectedItems.enumerated() {
                data.selectedCount = idx + 1
            }
            self.imageDetailViewController?.reloadData()
        }
    }
    private var showDetailPageIndex: Int = 0

    weak var imageDetailViewController: ImageDetailViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func getSize(_ data: Any?, width: CGFloat) -> CGSize {
        return CGSize(width: width, height: fromNibSize().h)
    }

    func configure(_ data: Any?) {

        collectionView.adapterData = makeAdapterData()
        collectionView.reloadData()
    }

    func didSelect(collectionView: UICollectionView, indexPath: IndexPath) {

    }

    func makeAdapterData() -> UICollectionViewAdapterData {
        let adapterData = UICollectionViewAdapterData()
        let sectionInfo = UICollectionViewAdapterData.SectionInfo()

        let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: selectedItems.count,
                                                            cellType: PhothAddCell.self) { [weak self]  ( _, data) in
            guard let self = self else { return }
            guard self.selectedItems.count < 10 else {
                alert(title: "알림", message: "최대 10까지 등록이 가능합니다.")
                return
            }

            let vc = ImageCollectionViewController.pushViewController()
            vc.delegate = self
            vc.beforeSelectedCount = self.selectedItems.count
        }
        sectionInfo.cells.append(cellInfo)

        for subData in selectedItems {
            let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: subData,
                                                                cellType: PhotoSubCell.self) { [weak self]  ( name, data) in
                guard let self = self else { return }
                if name == PhotoSubCell.IMAGE_CLICK_KEY, let data = data as? (index:Int, image:UIImage) {
                    self.showDetailPageIndex = data.index
                    let vc = ImageDetailViewController.pushViewController()
                    vc.delegate = self
                    vc.imageDataList = self.selectedItems
                    vc.nowIndex = data.index - 1
                    vc.defaultImage = data.image
                    self.imageDetailViewController = vc
                }
                else if name == PhotoSubCell.IMAGE_REMOVE_KEY, let index = data as? Int {
                    self.selectedItems.remove(at: index - 1)
                    self.collectionView.adapterData = self.makeAdapterData()
                    self.collectionView.performBatchUpdates {
                        self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                    } completion: { _ in
                        self.collectionView.reloadData()
                    }


                }
            }
            sectionInfo.cells.append(cellInfo)

        }
        adapterData.sectionList.append(sectionInfo)
        return adapterData
    }

}

extension PhotoCell: ImageCollectionViewControllerDelegate {
    func setSelectItems(items: [UnslpashImageModel]) {
        self.selectedItems.append(contentsOf: items)
        collectionView.adapterData = makeAdapterData()
        collectionView.reloadData()
    }
}

extension PhotoCell: ImageDetailViewControllerDelegate {
    func didChange(index: Int) {
        showDetailPageIndex = index
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
        collectionView.layoutIfNeeded()
    }

    func getStartRect() -> CGRect {
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: self.showDetailPageIndex, section: 0)) as? PhotoSubCell {
//                    cell.imageView.isHidden = true
            return cell.getImageWindowsRect()
        }
        return .zero
    }

    func willStartAnimation() {

    }

    func didEndAnimation() {
        self.imageDetailViewController = nil
    }

    func didSelected(selected: Bool, data: UnslpashImageModel) {
        if selected {
            self.selectedItems.append(data)

        }
        else {
            self.selectedItems.remove(object: data)
        }
        self.collectionView.adapterData = self.makeAdapterData()
        self.collectionView.reloadData()
    }


}
