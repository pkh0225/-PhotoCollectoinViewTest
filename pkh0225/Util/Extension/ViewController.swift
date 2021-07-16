//
//  ViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/11.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!

    private let accessQueue = DispatchQueue(label: "accessQueue_ViewController", qos: .userInitiated, attributes: .concurrent)
    private var pageIndex: Int = 0
    private var imageDataList = [UnslpashImageModel]()
    private var showDetailPageIndex: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        NavigationManager.shared.mainNavigation = self.navigationController
        setup()
        requestImageData()
    }

    func setup() {
        self.pageIndex = 0
        self.collectionView.adapterHasNext = true

        self.collectionView.didScrollCallback { scrollVoew in
            print("y : \(scrollVoew.contentOffset.y)")
        }
    }

    func requestImageData() {
        pageIndex += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if pageIndex == 1 {
            indicatorView.startAnimating()
        }
        UnslpashImageModelList.getResetData(pageIndex: pageIndex) { requestData in
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
                self.indicatorView.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

    func requestSearchData() {
        pageIndex += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if pageIndex == 1 {
            indicatorView.startAnimating()
        }
        UnslpashSearchImageModelList.getResetData(query: searchBar.text ?? "", pageIndex: pageIndex) { requestData in
            guard requestData.results.count > 0 else {
                self.collectionView.adapterHasNext = false
                return
            }
//            print(requestData.results.count)

            self.makeAdapterData(requestData.results) { [weak self] adapterData in
                guard let self = self, let adapterData = adapterData else { return }
                if self.pageIndex < requestData.total_pages {
                    self.collectionView.adapterHasNext = true
                }
                self.collectionView.adapterRequestNextClosure = { [weak self] in
                    guard let `self` = self else { return }
                    self.requestSearchData()
                }
                self.setImageDataList(requestData.results)
                self.setCollectionViewData(adapterData)
                self.indicatorView.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                                                                    cellType: MainImageCell.self) { [weak self]  ( _, data) in
                    guard let self = self, let data = data as? ImageAnimationInfo else { return }
                    self.showImageDetail(data)
                }
                sectionInfo.cells.append(cellInfo)
            }
            adapterData.sectionList.append(sectionInfo)
            DispatchQueue.main.async {
                completion(adapterData)
            }

        }
    }

    func showImageDetail(_ data: ImageAnimationInfo) {
        searchBar.resignFirstResponder()
        self.showDetailPageIndex = data.index
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController {
            vc.imageDataList = self.imageDataList
            vc.nowIndex = data.index
            vc.defaultImage = data.image
            vc.didChange = { [weak self]  index in
                guard let self = self else { return }
                print("didChange: \(index)")
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
            vc.getStartRectCallBack = { [weak self] in
                guard let self = self else { return . zero }
                print("getStartRectCallBack: \(self.showDetailPageIndex)")

                if let cell = self.collectionView.cellForItem(at: IndexPath(row: self.showDetailPageIndex, section: 0)) as? MainImageCell {
//                    cell.imageView.isHidden = true
                    return cell.getImageWindowsRect()
                }
                print("CGRect.zero")
                return .zero
            }
            vc.endCallBack = {
//                if let cell = self.collectionView.cellForItem(at: IndexPath(row: self.showDetailPageIndex, section: 0)) as? MainImageCell {
//                    cell.imageView.isHidden = false
//                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
