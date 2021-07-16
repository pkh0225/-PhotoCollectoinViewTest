//
//  CategoryViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class CategoryViewController: BaseTitleBarController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var collectionView: UICollectionView!

    private lazy var accessQueue = DispatchQueue(label: "accessQueue_\(self.className)", qos: .userInitiated, attributes: .concurrent)

    lazy var categories: [CategoryModel] = {
        return [
            CategoryModel(id: 1, categoryName: "디지털/가전"),
            CategoryModel(id: 2, categoryName: "게임"),
            CategoryModel(id: 3, categoryName: "스포츠/레저"),
            CategoryModel(id: 4, categoryName: "유아/아동용품"),
            CategoryModel(id: 5, categoryName: "여성패션/잡화"),
            CategoryModel(id: 6, categoryName: "뷰티/미용"),
            CategoryModel(id: 7, categoryName: "남성패션/잡화"),
            CategoryModel(id: 8, categoryName: "생활/식품"),
            CategoryModel(id: 9, categoryName: "가구"),
            CategoryModel(id: 10, categoryName: "도서/티켓/취미"),
            CategoryModel(id: 11, categoryName: "기타"),
        ]
    }()

    var completionClosure: ((CategoryModel) -> Void)? = nil
    var selectedId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        titleBarViewController?.isBackButton = true
        titleBarViewController?.delegate = self

        setSelectData(id: selectedId)

        makeAdapterData { [weak self] adapterData in
            guard let self = self else { return }
            self.collectionView.adapterData = adapterData
            self.collectionView.reloadData()
        }
    }
    

    /// 비동기 처리된 Adapter Data 생성
    /// - Parameter completion: UICollectionViewAdapterData
    func makeAdapterData(completion: @escaping (_ adapterData: UICollectionViewAdapterData?) -> Void ) {
        // 서버 통신이 들어가면 통기화 처리가 필요하기에 barrier 처리 됨
        accessQueue.async(flags: .barrier) {
            let adapterData = UICollectionViewAdapterData()
            let sectionInfo = UICollectionViewAdapterData.SectionInfo()

            for subData in self.categories {
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: subData,
                                                                    cellType: CategoryCell.self) { [weak self]  ( _, data) in
                    guard let self = self, let data = data as? CategoryModel else { return }

                    self.setSelectData(id: data.id)
                    self.completionClosure?(data)
                    self.navigationController?.popViewController(animated: true)
                }
                sectionInfo.cells.append(cellInfo)

            }
            
            adapterData.sectionList.append(sectionInfo)
            DispatchQueue.main.async {
                completion(adapterData)
            }
        }
    }

    @discardableResult
    func setSelectData(id: Int) -> CategoryModel? {
        var obj: CategoryModel?
        for data in categories {
            if data.id == id {
                data.isSelected = true
                obj = data
            }
            else {
                data.isSelected = false
            }
        }

        return obj
    }
}

extension CategoryViewController: TitleBarViewControllerDelegate {
    func onBackButton() {

    }
}
