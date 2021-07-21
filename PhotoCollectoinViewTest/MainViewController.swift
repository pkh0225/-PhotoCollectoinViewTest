//
//  ViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class MainViewController: BaseTitleBarController {

    @IBOutlet weak var bottomContainerViewB: UIView!
    @IBOutlet weak var bottomContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var regionButton: UIButton!
    @IBOutlet weak var hideKeyboardButton: UIButton!
    @IBOutlet weak var addTextButton: UIButton!

    private lazy var accessQueue = DispatchQueue(label: "accessQueue_\(self.className)", qos: .userInitiated, attributes: .concurrent)

    var data: FleaMarketArticleModel = FleaMarketArticleModel()


    override func viewDidLoad() {
        super.viewDidLoad()
        NavigationManager.shared.mainNavigation = self.navigationController
        titleBarViewController?.isSubmitButton = true
        titleBarViewController?.delegate = self
        registerForNotifications()
        hideKeyboardButton.gone(.width)
        reloadData()
        
    }

    func reloadData() {
        makeAdapterData {[weak self] adapterData in
            guard let self = self else { return }
            self.collectionView.adapterData = adapterData
            self.collectionView.reloadData()
        }
    }

    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
                    guard let self = self, let data = data as? [UnslpashImageModel] else { return }
                    self.data.images = data
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
                if self.data.category?.id ?? 0 == 0 {
                    contentObj = SelectLabelCellModel(title: "카테고리 선택")
                }
                else {
                    contentObj = SelectLabelCellModel(title: self.data.category?.categoryName ?? "")
                }
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: contentObj,
                                                                    cellType: SelectLabelCell.self) { [weak self]  ( _, data) in
                    guard let self = self else { return }
                    let vc = CategoryViewController.pushViewController()
                    vc.selectedId = self.data.category?.id ?? 0
                    vc.completionClosure = { [weak self] obj in
                        guard let self = self else { return }
                        self.data.category = obj
                        self.reloadData()
                    }
                }
                sectionInfo.cells.append(cellInfo)
            }
//            do {
//                var contentObj: SelectLabelCellModel
//                if self.data.region?.id ?? 0 == 0 {
//                    contentObj = SelectLabelCellModel(title: "게시글 보여줄 동네 고르기")
//                }
//                else {
//                    contentObj = SelectLabelCellModel(title: "\(self.data.region?.regionName ?? "") 근처 동네 \(self.data.region?.townCount ?? 0)개")
//                }
//                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: contentObj,
//                                                                    cellType: SelectLabelCell.self) { [weak self]  ( _, data) in
//                    guard let self = self else { return }
//                    let vc = RegionViewController.pushViewController()
//                    vc.region = self.data.region
//                    vc.completionClosure = { [weak self] obj in
//                        guard let self = self else { return }
//                        self.data.region = obj
//                        self.reloadData()
//                    }
//                }
//                sectionInfo.cells.append(cellInfo)
//            }
            do {
                if self.data.price == nil {
                    self.data.price = PriceModel()
                }
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: self.data.price,
                                                                    cellType: InputPriceCell.self) { [weak self]  ( name, data) in
                    guard let self = self, let data = data as? PriceModel  else { return }
//                    print("\(name): \(data)")
                    self.data.price = data
                }
                sectionInfo.cells.append(cellInfo)
            }
            do {
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: self.data.content,
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
    @IBAction func onRegionButton(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = RegionViewController.pushViewController()
        vc.region = self.data.region
        vc.completionClosure = { [weak self] obj in
            guard let self = self else { return }
            self.data.region = obj
            self.regionButton.setTitle("\(self.data.region?.regionName ?? "") 근처 동네 \(self.data.region?.townCount ?? 0)개", for: .normal)
        }
    }

    @IBAction func onAddTextButton(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = AddTextViewController.pushViewController()
        vc.completionClosure = { [weak self] str in
            guard let self = self else { return }
            self.data.content += "\n\(str)"
            self.reloadData()
        }
    }
    @IBAction func onHideKeyboardButton(_ sender: UIButton) {
        view.endEditing(true)
    }
}

extension MainViewController: TitleBarViewControllerDelegate {
    func onSubmitButton() {
        var errorMessages: [String] = []

        if self.data.images.count < 1 {
            errorMessages.append("- 이미지를 선택애주세요.")
        }

        if self.data.title.isValid == false {
            errorMessages.append("- 글 제목을 입력애주세요.")
        }
        if self.data.category?.id ?? 0 == 0 {
            errorMessages.append("- 카테고리를 선택해주세요.")
        }

        if self.data.region?.id ?? 0 == 0 {
            errorMessages.append("- 동네를 선택해주세요.")
        }

        if self.data.price?.price ?? -1 < 0 {
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

extension MainViewController {
    // MARK: - Notifications
    @objc func keyboardWillChangeFrameNotification(_ notification: Notification) {
        self.handleKeyboardNotification(notification)
    }

    func handleKeyboardNotification(_ notification: Notification, completion: ((_ finished: Bool) -> Void)? = nil) {
        //    NSLog(@"userInfo = %@", userInfo);
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardEndFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardEndFrame: CGRect = keyboardEndFrameValue.cgRectValue
        if keyboardEndFrame.isEmpty {
            return
        }

        guard let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        guard let rawAnimationCurveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else { return }
        guard let animationCurveOption = UIView.AnimationCurve(rawValue: rawAnimationCurveValue) else { return }


        var height: CGFloat = 0
        if keyboardEndFrame.origin.y < view.h {
            height = keyboardEndFrame.size.height
            let window = UIApplication.shared.windows[0]
            height -= window.safeAreaInsets.bottom
        }

        if animationDuration > 0 {
            UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: UIView.AnimationOptions(rawValue: UInt(animationCurveOption.rawValue)), animations: {
                self.bottomContainerViewBottomConstraint.constant = height
                if height == 0 {
                    self.hideKeyboardButton.gone(.width)
                }
                else {
                    self.hideKeyboardButton.goneRemove(.width)
                }

                self.view.layoutIfNeeded()
            }) { finished in
                self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            }
        }
        else {
            self.bottomContainerViewBottomConstraint.constant = height
            self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        }


    }
}
