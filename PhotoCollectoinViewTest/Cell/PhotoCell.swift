//
//  PhotoCell.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class PhotoCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static var itemCount: Int = 1

    @IBOutlet weak var subCollectionView: UICollectionView!

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
            self.actionClosure?("", selectedItems)
        }
    }
    private var animationPageIndex: Int = 0

    weak var imageDetailViewController: ImageDetailViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func getSize(_ data: Any? = nil, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: fromXibSize().h)
    }

    func configure(_ data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        subCollectionView.adapterData = makeAdapterData()
        subCollectionView.reloadData()
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
                                                                cellType: PhotoSubCell.self) { [weak self]  (name, data) in
                guard let self = self else { return }
                print("\(name) data: \(data)")
                if name == PhotoSubCell.IMAGE_CLICK_KEY, let data = data as? (index:Int, image:UIImage) {
                    self.animationPageIndex = data.index
                    let vc = ImageDetailViewController.pushViewController()
                    vc.delegate = self
                    vc.imageDataList = self.selectedItems
                    vc.nowIndex = data.index - 1
                    vc.defaultImage = data.image
                    self.imageDetailViewController = vc
                }
                else if name == PhotoSubCell.IMAGE_REMOVE_KEY, let index = data as? Int {
                    self.selectedItems.remove(at: index - 1)
                    self.subCollectionView.adapterData = self.makeAdapterData()
                    self.subCollectionView.performBatchUpdates {
                        self.subCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                    } completion: { _ in
                        self.subCollectionView.reloadData()
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
        subCollectionView.adapterData = makeAdapterData()
        subCollectionView.reloadData()
    }
}

extension PhotoCell: ImageDetailViewControllerDelegate {
    func didChange(index: Int) {
        animationPageIndex = index + 1
        subCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
        subCollectionView.layoutIfNeeded()

        print("\(#function) animationPageIndex: \(animationPageIndex)")
    }

    func getStartRect() -> CGRect {
        if let cell = self.subCollectionView.cellForItem(at: IndexPath(row: self.animationPageIndex, section: 0)) as? PhotoSubCell {
            print("\(#function) animationPageIndex: \(animationPageIndex)")
            return cell.getImageWindowsRect()
        }
        return .zero
    }

    func willPushStartAnimation() {
        print(#function)
        cellAllHiddenFalse()
        cellHidden(isHidden: true, index: self.animationPageIndex)
    }

    func didPushEndAnimation() {
        print(#function)
        cellHidden(isHidden: false, index: self.animationPageIndex)
    }

    func willPopStartAnimation() {
        print(#function)
        cellAllHiddenFalse()
        cellHidden(isHidden: true, index: self.animationPageIndex)
    }

    func didPopEndAnimation() {
        print(#function)
        cellHidden(isHidden: false, index: self.animationPageIndex)
        self.imageDetailViewController = nil
    }

    func panPopCanelAnimation() {
        print(#function)
        cellHidden(isHidden: false, index: self.animationPageIndex)
    }

    func didSelected(selected: Bool, data: UnslpashImageModel) {
        if selected {
            self.selectedItems.append(data)
        }
        else {
            self.selectedItems.remove(object: data)
        }
        self.subCollectionView.adapterData = self.makeAdapterData()
        self.subCollectionView.reloadData()
    }


    func cellAllHiddenFalse() {
        self.subCollectionView.visibleCells.forEach({ $0.isHidden = false })
    }

    func cellHidden(isHidden: Bool, index: Int) {
        if let cell = self.subCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PhotoSubCell {
            cell.isHidden = isHidden
        }
    }
}
