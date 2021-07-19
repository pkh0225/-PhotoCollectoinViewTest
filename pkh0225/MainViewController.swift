//
//  ViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class MainViewController: BaseTitleBarController {

    @IBOutlet weak var collectionView: UICollectionView!
    private lazy var accessQueue = DispatchQueue(label: "accessQueue_\(self.className)", qos: .userInitiated, attributes: .concurrent)

    var data: FleaMarketArticleModel = FleaMarketArticleModel()


    override func viewDidLoad() {
        super.viewDidLoad()
        NavigationManager.shared.mainNavigation = self.navigationController

        titleBarViewController?.isSubmitButton = true
        titleBarViewController?.delegate = self

        makeAdapterData {[weak self] adapterData in
            guard let self = self else { return }
            self.collectionView.adapterData = adapterData
            self.collectionView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    /// 비동기 처리된 Adapter Data 생성
    /// - Parameter completion: UICollectionViewAdapterData
    func makeAdapterData(completion: @escaping (_ adapterData: UICollectionViewAdapterData?) -> Void ) {
        // 서버 통신이 들어가면 통기화 처리가 필요하기에 barrier 처리 됨
        accessQueue.async(flags: .barrier) {
            let adapterData = UICollectionViewAdapterData()
            let sectionInfo = UICollectionViewAdapterData.SectionInfo()

            do {
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: nil,
                                                                    cellType: PhotoCell.self) { [weak self]  ( _, data) in
                    guard let self = self else { return }
                }
                sectionInfo.cells.append(cellInfo)
            }
            do {
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: nil,
                                                                    cellType: InputTitleCell.self) { [weak self]  ( _, data) in
                    guard let self = self, let data = data as? String else { return }
                    self.data.title = data
                }
                sectionInfo.cells.append(cellInfo)
            }
            do {
                var contentObj: SelectLabelCellModel
                if self.data.categoryID == 0 {
                    contentObj = SelectLabelCellModel(title: "카테고리 선택")
                }
                else {
                    contentObj = SelectLabelCellModel(title: self.data.categoryName)
                }
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: contentObj,
                                                                    cellType: SelectLabelCell.self) { [weak self]  ( _, data) in
                    guard let self = self else { return }
                    let vc = CategoryViewController.pushViewController()
                    vc.selectedId = self.data.categoryID
                    vc.completionClosure = { [weak self] obj in
                        guard let self = self else { return }
                        self.data.categoryID = obj.id
                        self.data.categoryName = obj.categoryName

                        self.makeAdapterData {[weak self] adapterData in
                            guard let self = self else { return }
                            self.collectionView.adapterData = adapterData
                            self.collectionView.reloadData()
                        }
                    }
                }
                sectionInfo.cells.append(cellInfo)
            }
            do {
                var contentObj: SelectLabelCellModel
                if self.data.regionID == 0 {
                    contentObj = SelectLabelCellModel(title: "게시글 보여줄 동네 고르기")
                }
                else {
                    contentObj = SelectLabelCellModel(title: self.data.regionNsme)
                }
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: contentObj,
                                                                    cellType: SelectLabelCell.self) { [weak self]  ( _, data) in
                    guard let self = self else { return }
                    let vc = RegioinViewController.pushViewController()
                    vc.selectedId = self.data.categoryID
                    vc.completionClosure = { [weak self] obj in
                        guard let self = self else { return }
                        self.data.regionID = obj.id
                        self.data.regionNsme = obj.regionName

                        self.makeAdapterData {[weak self] adapterData in
                            guard let self = self else { return }
                            self.collectionView.adapterData = adapterData
                            self.collectionView.reloadData()
                        }
                    }
                }
                sectionInfo.cells.append(cellInfo)
            }
            do {
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: nil,
                                                                    cellType: InputPriceCell.self) { [weak self]  ( name, data) in
                    guard let self = self  else { return }
//                    print("\(name): \(data)")
                    if name == InputPriceCell.PRICE_KEY, let data = data as? String {
                        guard data.isValid else {
                            self.data.price = -1
                            return
                        }
                        self.data.price = data.replace(",", "").toInt()
                    }
                    else if name == InputPriceCell.SUGGEST_KEY, let data = data as? Bool {
                        self.data.isSuggestion = data
                    }
                }
                sectionInfo.cells.append(cellInfo)
            }
            do {
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: nil,
                                                                    cellType: InputDescriptionCell.self) { [weak self]  ( _, data) in
                    guard let self = self, let data = data as? String else { return }
                    self.data.content = data
                }
                sectionInfo.cells.append(cellInfo)
            }

            adapterData.sectionList.append(sectionInfo)
            DispatchQueue.main.async {
                completion(adapterData)
            }

        }
    }

}

extension MainViewController: TitleBarViewControllerDelegate {
    func onSubmitButton() {
        var errorMessages: [String] = []

        if self.data.title.isValid == false {
            errorMessages.append("- 글 제목을 입력애주세요.")
        }
        if self.data.categoryID == 0 {
            errorMessages.append("- 카테고리를 선택해주세요.")
        }

        if self.data.regionID == 0 {
            errorMessages.append("- 동네를 선택해주세요.")
        }

        if self.data.price < 0 {
            errorMessages.append("- 가격을 입력해주세요.")
        }

        if self.data.content.isValid == false {
            errorMessages.append("- 내용을 입력해주세요.")
        }

        let title: String = errorMessages.isEmpty ? "성공": "실패"
        let message: String? = errorMessages.isEmpty ? nil : errorMessages.joined(separator: "\n")
        alert(title: title, message: message)

    }
}
