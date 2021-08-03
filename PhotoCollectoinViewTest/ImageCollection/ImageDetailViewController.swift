//
//  ImageDetailViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/16.
//

import UIKit

private let ANIMATION_DURATUION = 0.2

protocol ImageDetailViewControllerDelegate: AnyObject {
    func didChange(index: Int)
    func getStartRect() -> CGRect
    func willPushStartAnimation()
    func didPushEndAnimation()
    func willPopStartAnimation()
    func didPopEndAnimation()
    func panPopCanelAnimation()
    func didSelected(selected: Bool, data: UnslpashImageModel)
}

class ImageDetailViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!

    weak var delegate: ImageDetailViewControllerDelegate?

    lazy var tempImgeView: UIImageView = {
        let v = UIImageView()
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        self.view.addSubview(v)
        return v
    }()
    private let accessQueue = DispatchQueue(label: "accessQueue_ImageDetailViewController", qos: .userInitiated, attributes: .concurrent)
    var imageDataList = [UnslpashImageModel]()
    var nowIndex: Int = 0
    var popAnimator: PopAnimator?
    var defaultImage: UIImage?
    private var popAnimationCallBack: VoidClosure?
    var panRecognizer: UIPanGestureRecognizer?
    var beforeSelectedCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popAnimator = PopAnimator(animation: { [weak self] _, toViewController, completion in
            guard let `self` = self else { return }
            self.popAnimation(toViewController: toViewController, completion: completion)
        })

        makeAdapterData(imageDataList) { [weak self] adapterData in
            guard let self = self, let adapterData = adapterData else { return }
            self.collectionView.adapterData = adapterData
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.collectionView.scrollToItem(at: IndexPath(row: self.nowIndex, section: 0), at: .centeredHorizontally, animated: false)
        }


        collectionView.didScrollCallback { scrollView in
            let x: CGFloat = scrollView.contentOffset.x + (self.collectionView.frame.size.width / 2)
            let horizontalNowPage = Int( x / self.collectionView.frame.size.width)
            guard self.nowIndex != horizontalNowPage else { return }
            self.nowIndex = horizontalNowPage
            self.delegate?.didChange(index: self.nowIndex)
        }

        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizer(_:)))
        view.addGestureRecognizer(panRecognizer!)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func onCloseButton(_ sender: UIButton) {
        self.delegate?.didChange(index: self.nowIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func makeAdapterData(_ dataList: [UnslpashImageModel], completion: @escaping (_ adapterData: UICollectionViewAdapterData?) -> Void ) {
        accessQueue.async(flags: .barrier) {
            let adapterData = UICollectionViewAdapterData()
            let sectionInfo = UICollectionViewAdapterData.SectionInfo()
            for (idx, subData) in dataList.enumerated() {
                if idx == self.nowIndex {
                    subData.urls?.tempImage = self.defaultImage
                }
                let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: subData,
                                                                    sizeClosure: { [weak self] in
                                                                        guard let self = self else { return .zero }
                                                                        return CGSize(width: self.collectionView.frame.size.w + self.collectionView.trailingConstraint, height: self.collectionView.frame.size.height)
                                                                    },
                                                                    cellType: DetailImageCell.self) { [weak self] (name, data) in
                    guard let self = self, let data = data as? UnslpashImageModel else { return }

                    if name == DetailImageCell.SELECTED_ADD_KEY {
                        self.delegate?.didSelected(selected: true, data: data)
                        self.collectionView.reloadData()
                    }
                    else if name == DetailImageCell.SELECTED_REMOVE_KEY {
                        self.delegate?.didSelected(selected: false, data: data)
                        self.collectionView.reloadData()
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

    func addImageData(_ dataList: [UnslpashImageModel]) {
        imageDataList.append(contentsOf: dataList)
        makeAdapterData(dataList) { [weak self] adapterData in
            guard let self = self, let adapterData = adapterData, let cells = adapterData.sectionList[safe: 0]?.cells else { return }
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

    func reloadData() {
        collectionView.reloadData()
    }
}


// MARK: - Push, Pop Animation
extension ImageDetailViewController: NavigationAnimatorAble {
    var pushAnimation: PushAnimator? {
        let animator = PushAnimator { [weak self] fromViewController, _, completion in
            guard let `self` = self else { return }
            self.pushAnimation(fromViewController: fromViewController, completion: completion)
        }
        return animator
    }

    var popAnimation: PopAnimator? {
        return self.popAnimator
    }

    func getImageCenter() -> CGPoint {
        var rect = self.collectionView.frame
        rect.w += collectionView.trailingConstraint // 이미지 오늘쪽 여백을 주기위해 마진값이 들어 있음
        return rect.center
    }

    func getImageSize() -> CGSize {
        return tempImgeView.image?.size.ratioSize(setWidth: self.view.frame.size.width) ?? .zero
    }

    func pushAnimation(fromViewController: UIViewController, completion: @escaping () -> Void) {
        self.delegate?.willPushStartAnimation()
        view.backgroundColor = UIColor.clear
        view.layoutIfNeeded()
        closeButton.alpha = 0
        tempImgeView.isHidden = false
        tempImgeView.image = defaultImage
        tempImgeView.frame = self.delegate?.getStartRect() ?? .zero
        collectionView.isHidden = true
        let newSize: CGSize = self.getImageSize()
        let center: CGPoint = self.getImageCenter()

        UIView.animate(withDuration:ANIMATION_DURATUION, delay: 0, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            self.tempImgeView.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            self.tempImgeView.center = center
            self.closeButton.alpha = 1.0
            self.view.layoutIfNeeded()
        }) { _ in
            self.tempImgeView.isHidden = true
            self.collectionView.isHidden = false
            self.delegate?.didPushEndAnimation()
            completion()
        }
    }

    func popAnimation(toViewController: UIViewController, completion: @escaping () -> Void) {
        if preferredInterfaceOrientationForPresentation != .portrait {
            completion()
            return
        }
        guard let cell = collectionView.visibleCells.first as? DetailImageCell  else { return }
        let newSize: CGSize = self.getImageSize()
        let center: CGPoint = self.getImageCenter()


        self.delegate?.willPopStartAnimation()
        self.tempImgeView.image = cell.imageView.image

        if popAnimator?.interactionController == nil {
            collectionView.isHidden = true
            tempImgeView.isHidden = false

            tempImgeView.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            tempImgeView.center = center
            view.layoutIfNeeded()

            UIView.animate(withDuration: ANIMATION_DURATUION, delay: 0, options: .curveEaseInOut, animations: {
                self.view.backgroundColor = UIColor.clear
                self.tempImgeView.frame = self.delegate?.getStartRect() ?? .zero
                self.closeButton.alpha = 0
                self.view.layoutIfNeeded()
            }) { _ in
                self.collectionView.isHidden = false
                self.tempImgeView.isHidden = true
                self.delegate?.didPopEndAnimation()
                completion()
            }
        }
        else {
            popAnimationCallBack = completion
            collectionView.isHidden = true
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.view.backgroundColor = UIColor.clear
                self.closeButton.alpha = 0
                self.view.layoutIfNeeded()
            }) { _ in
            }
        }
    }
}

// MARK: - Gesture
extension ImageDetailViewController {
    @objc func panGestureRecognizer(_ recognizer: UIPanGestureRecognizer) {
        guard let cell = collectionView.visibleCells.first as? DetailImageCell, let scrollView = cell.scrollView else { return }

        let velocity: CGPoint = recognizer.velocity(in: recognizer.view)
        let isVerticalGesture: Bool = abs(Float(velocity.y)) > abs(Float(velocity.x))
        if recognizer.state == .began {
            if scrollView.zoomScale != 1.0 || isVerticalGesture == false || (velocity.y) < 0 {
                return
            }
//            self.delegate?.didChange(index: self.nowIndex)
            self.delegate?.willPopStartAnimation()
            self.tempImgeView.image = cell.imageView.image
            if (navigationController?.viewControllers.count ?? 0) > 1 {
                popAnimator?.interactionController = UIPercentDrivenInteractiveTransition()
                navigationController?.popViewController(animated: true)
            }
            tempImgeView.isHidden = false
            let newSize: CGSize = self.getImageSize()
            let center: CGPoint = self.getImageCenter()
            tempImgeView.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            tempImgeView.center = center
        }
        else if recognizer.state == .changed {
            if popAnimator?.interactionController == nil {
                return
            }
            let translation: CGPoint = recognizer.translation(in: view)
            let d: CGFloat = (translation.y) / view.bounds.height
            popAnimator?.interactionController?.update(d)
            let rate: CGFloat = (0.5 - d) + 0.5
            var point: CGPoint = recognizer.translation(in: view.window)
            point.x += self.view.center.x
            point.y += self.view.center.y
            let newSize: CGSize = tempImgeView.image?.size.ratioSize(setWidth: self.view.frame.size.width) ?? .zero
            tempImgeView.frame.size.width = min(newSize.width, newSize.width * rate)
            tempImgeView.frame.size.height = min(newSize.height, newSize.height * rate)
            tempImgeView.center = point
        }
        else if recognizer.state == .ended {
            if popAnimator?.interactionController == nil {
                return
            }
            if (velocity.y) > 25 {
                panAnimationFinish()
            }
            else if (velocity.y) < -25 {
                panAnimationCancelFinish()
            }
            else {
                if tempImgeView.center.y > scrollView.frame.size.height / 2 {
                    panAnimationFinish()
                }
                else {
                    panAnimationCancelFinish()
                }
            }
            popAnimator?.interactionController = nil
        }
        else {
            panAnimationCancelFinish()
        }
    }
    func panAnimationFinish() {
        UIView.animate(withDuration: ANIMATION_DURATUION, animations: {
            self.popAnimator?.interactionController?.finish()
            self.tempImgeView.frame = self.delegate?.getStartRect() ?? .zero
        }) { _ in
            self.delegate?.didPopEndAnimation()
            self.popAnimationCallBack?()
        }
    }
    func panAnimationCancelFinish() {
        let newSize: CGSize = self.tempImgeView.image?.size.ratioSize(setWidth: self.view.frame.size.width) ?? .zero
        let center: CGPoint = self.view.center
        UIView.animate(withDuration: 0.2, animations: {
            self.popAnimator?.interactionController?.cancel()
            self.tempImgeView.frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            self.tempImgeView.center = center
        }) { _ in
            self.collectionView.isHidden = false
            self.tempImgeView.isHidden = true
            self.popAnimationCallBack?()
            self.delegate?.panPopCanelAnimation()
        }
    }
}
