//
//  RegioinViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class RegioinViewController: BaseTitleBarController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var collectionView: UICollectionView!

    private lazy var accessQueue = DispatchQueue(label: "accessQueue_\(self.className)", qos: .userInitiated, attributes: .concurrent)

    lazy var regions: [RegionModel] = {[
        RegionModel(id: 1, regionName: "내동네"),
        RegionModel(id: 2, regionName: "인접동네"),
        RegionModel(id: 3, regionName: "근처동네")
    ]
    }()

    var completionClosure: ((RegionModel) -> Void)? = nil
    var selectedId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        titleBarViewController?.isBackButton = true

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

            for subData in self.regions {
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: subData,
                                                                    cellType: CategoryCell.self) { [weak self]  ( _, data) in
                    guard let self = self, let data = data as? RegionModel else { return }

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
    func setSelectData(id: Int) -> RegionModel? {
        var obj: RegionModel?
        for data in regions {
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
