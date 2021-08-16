//
//  ViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/16.
//

import UIKit

protocol ImageCollectionViewControllerDelegate: AnyObject {
    func setSelectItems(items: [UnslpashImageModel])
}

class ImageCollectionViewController: BaseTitleBarController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var indicatorBackView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        self.view.addSubview(v)
        v.centerInSuperView()
        v.autoresizingMask = []
        v.backgroundColor = UIColor(hex: 0x000000, alpha: 0.7)
        v.cornerRadius = 10
        return v
    }()

    lazy var indicatorView: UIActivityIndicatorView = {
        if #available(iOS 13, *) {
            let i = UIActivityIndicatorView(style: .large)
            indicatorBackView.addSubview(i)
            i.centerInSuperView()
            i.autoresizingMask = []
            i.color = .white
            return i
        }
        else {
            let i = UIActivityIndicatorView(style: .whiteLarge)
            indicatorBackView.addSubview(i)
            i.centerInSuperView()
            i.autoresizingMask = []
            i.color = .white
            return i
        }

    }()

    private let accessQueue = DispatchQueue(label: "accessQueue_ViewController", qos: .userInitiated, attributes: .concurrent)
    private var pageIndex: Int = 0
    private var imageDataList = [UnslpashImageModel]()
    private var showDetailPageIndex: Int = 0
    private var urlTask: URLSessionDataTask?

    private var selectedItems = [UnslpashImageModel]() {
        willSet {
            selectedItems.forEach { $0.selectedCount = 0 }
        }
        didSet {
            for (idx, data) in selectedItems.enumerated() {
                data.selectedCount = beforeSelectedCount + idx + 1
            }
            collectionView.reloadData()
            self.titleBarViewController?.titleString = "\(self.title ?? "")"
            if self.selectedItems.count > 0 {
                self.titleBarViewController?.titleString += " (\(self.selectedItems.count + beforeSelectedCount))"
            }
        }
    }

    weak var delegate: ImageCollectionViewControllerDelegate?

    var beforeSelectedCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        titleBarViewController?.isBackButton = true
        titleBarViewController?.isSubmitButton = true
        titleBarViewController?.submitTitle = "선택"
        titleBarViewController?.delegate = self

        setup()
        requestImageData()
    }

    func setup() {
        self.titleBarViewController?.titleString = "\(self.title ?? "")"
        self.selectedItems.removeAll()
        self.pageIndex = 0
        self.collectionView.adapterHasNext = true

    }

    func startIndicatorView() {
        indicatorBackView.isHidden = false
        indicatorView.startAnimating()
    }

    func stopIndicatorView() {
        indicatorBackView.isHidden = true
        indicatorView.stopAnimating()
    }

    func requestImageData() {
        pageIndex += 1
        if pageIndex == 1 {
            startIndicatorView()
        }
        urlTask = UnslpashImageModelList.getResetData(pageIndex: pageIndex) { requestData in
            guard requestData.dataList.count > 0 else {
                self.collectionView.adapterHasNext = false
                return
            }
//            print(requestData.dataList.count)

            self.makeAdapterData(requestData.dataList) { [weak self] adapterData in
                guard let self = self, let adapterData = adapterData else { return }
                self.collectionView.adapterRequestNextClosure = { [weak self] in
                    guard let `self` = self else { return }
                    self.requestImageData()
                }
                self.collectionView.adapterHasNext = true
                self.setImageDataList(requestData.dataList)
                self.setCollectionViewData(adapterData)
                self.stopIndicatorView()
            }
        }
    }

    func requestSearchData() {
        pageIndex += 1
        if pageIndex == 1 {
            startIndicatorView()
        }
        urlTask = UnslpashSearchImageModelList.getResetData(query: searchBar.text ?? "", pageIndex: pageIndex) { requestData in
            guard requestData.results.count > 0 else {
                self.collectionView.adapterHasNext = false
                return
            }
//            print(requestData.results.count)

            self.makeAdapterData(requestData.results) { [weak self] adapterData in
                guard let self = self, let adapterData = adapterData else { return }
                if self.pageIndex == 1 {
                    self.collectionView.contentOffset = .zero
                }
                if self.pageIndex < requestData.total_pages {
                    self.collectionView.adapterHasNext = true
                }
                self.collectionView.adapterRequestNextClosure = { [weak self] in
                    guard let `self` = self else { return }
                    self.requestSearchData()
                }
                self.setImageDataList(requestData.results)
                self.setCollectionViewData(adapterData)
                self.stopIndicatorView()
            }
        }
    }

    func setImageDataList(_ dataList: [UnslpashImageModel]) {
        if self.pageIndex == 1 {
            self.imageDataList = dataList
        }
        else {
            self.imageDataList.append(contentsOf: dataList)
            if let vc = self.navigationController?.viewControllers.last as? ImageDetailViewController {
                vc.addImageData(dataList)
            }
        }
    }

    func setCollectionViewData(_ adapterData: UICollectionViewAdapterData?) {
        guard let adapterData = adapterData else { return }

        if self.pageIndex == 1 {
            self.collectionView.adapterData = adapterData
            self.collectionView.reloadData()
        }
        else if let cells = adapterData.sectionList[safe: 0]?.cells {
            self.collectionView.adapterData?.sectionList[safe: 0]?.cells.append(contentsOf: cells)
            let end: Int = self.collectionView.adapterData?.sectionList[safe: 0]?.cells.count ?? 0
            let start: Int = end - cells.count
            var insertIndexPath = [IndexPath]()
            for i in start..<end {
                insertIndexPath.append(IndexPath(item: i, section: 0))
            }
            self.collectionView.insertItems(at: insertIndexPath)
        }
    }

    func makeAdapterData(_ dataList: [UnslpashImageModel], completion: @escaping (_ adapterData: UICollectionViewAdapterData?) -> Void ) {
        accessQueue.async(flags: .barrier) {
            let adapterData = UICollectionViewAdapterData()
            let sectionInfo = UICollectionViewAdapterData.SectionInfo()
            for subData in dataList {
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: subData,
                                                                    cellType: MainImageCell.self) { [weak self]  ( name, data) in
                    guard let self = self else { return }

                    if name == MainImageCell.CLICK_KEY, let data = data as? ImageAnimationInfo {
                        self.showImageDetail(data)
                    }
                    else if name == MainImageCell.SELECTED_ADD_KEY, let data = data as? UnslpashImageModel {
                        self.setSelectItem(selected: true, data: data)
                    }
                    else if name == MainImageCell.SELECTED_REMOVE_KEY, let data = data as? UnslpashImageModel {
                        self.setSelectItem(selected: false, data: data)
                    }

                }
                sectionInfo.cells.append(cellInfo)
            }
            adapterData.sectionList.append(sectionInfo)
            DispatchQueue.main.async {
                completion(adapterData)
            }
        }
    }

    func setSelectItem(selected: Bool, data: UnslpashImageModel) {
        if selected {
            if self.selectedItems.count + self.beforeSelectedCount > 9 {
                data.isSeleected = false
                collectionView.reloadData()
                if let vc = self.navigationController?.viewControllers.last as? ImageDetailViewController {
                    vc.reloadData()
                }
                alert(title: "알림", message: "최대 10까지 가능합니다.")
                return
            }
            self.selectedItems.append(data)
        }
        else {
            self.selectedItems.remove(object: data)
        }
    }

    func showImageDetail(_ data: ImageAnimationInfo) {
        searchBar.resignFirstResponder()
        self.showDetailPageIndex = data.index
        let vc = ImageDetailViewController.pushViewController()
        vc.delegate = self
        vc.imageDataList = self.imageDataList
        vc.nowIndex = data.index
        vc.defaultImage = data.image
    }
}

//MARK: - UISearchBarDelegate
extension ImageCollectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        urlTask?.cancel()
        if searchText.isValid {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.onSearch), object: nil)
            self.perform(#selector(self.onSearch), with: nil, afterDelay: 0.2)
        }
        else {
            setup()
            requestImageData()
        }
    }

    @objc func onSearch() {
        setup()
        requestSearchData()
    }
}

extension ImageCollectionViewController: TitleBarViewControllerDelegate {
    func onBackButton() {

    }

    func onSubmitButton() {
        self.delegate?.setSelectItems(items: selectedItems)
        self.navigationController?.popViewController(animated: true)
    }
}

extension ImageCollectionViewController: ImageDetailViewControllerDelegate {
    func didChange(index: Int) {
        self.showDetailPageIndex = index

        self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: false)
        self.collectionView.layoutIfNeeded()

        if index > self.imageDataList.count - Request.per_page {
            if self.searchBar.text?.isValid ?? false {
                self.requestSearchData()
            }
            else {
                self.requestImageData()
            }
        }
    }

    func getStartRect() -> CGRect {
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: self.showDetailPageIndex, section: 0)) as? MainImageCell {
//                    cell.imageView.isHidden = true
            return cell.getImageWindowsRect()
        }
        return .zero
    }

    func didSelected(selected: Bool, data: UnslpashImageModel) {
        if selected {
            self.setSelectItem(selected: true, data: data)
        }
        else {
            self.setSelectItem(selected: false, data: data)
        }
        collectionView.reloadData()
    }

    func willPushStartAnimation() {
        self.collectionView.visibleCells.forEach { $0.isHidden = false }
        cellHidden(isHidden: true, index: self.showDetailPageIndex)
    }

    func didPushEndAnimation() {
        cellHidden(isHidden: false, index: self.showDetailPageIndex)
    }

    func willPopStartAnimation() {
        self.collectionView.visibleCells.forEach { $0.isHidden = false }
        cellHidden(isHidden: true, index: self.showDetailPageIndex)
    }

    func didPopEndAnimation() {
        cellHidden(isHidden: false, index: self.showDetailPageIndex)
    }
    func panPopCanelAnimation() {
        cellHidden(isHidden: false, index: self.showDetailPageIndex)
    }

    func cellHidden(isHidden: Bool, index: Int) {
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) {
            cell.isHidden = isHidden
        }
    }
}
