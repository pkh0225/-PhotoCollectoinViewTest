//
//  AddTextViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/19.
//

import UIKit

class AddTextViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceholderLabel: UILabel!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var inputBoxView: UIView!

    var completionClosure: ((String) -> Void)? = nil
    var popAnimator: PopAnimator?
    var dataList = [String]() {
        didSet {
            if dataList.count == 0 {
                self.collectionView.isHidden = true
            }
            else {
                self.collectionView.isHidden = false
                self.collectionView.adapterData = makeAdapterData()
                self.collectionView.reloadData()
            }

            UserDefaults.standard.setValue(dataList, forKey: "TEXTLIST_KEY")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.autocapitalizationType = .none
        self.textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.popAnimator = PopAnimator(animationType: .up, tagetViewController: self, tagetView: self.view)
        self.popAnimator?.addTargetView(self.collectionView)
        self.popAnimator?.animationCompletion = {
            self.view.endEditing(true)
        }

        if let list = UserDefaults.standard.object(forKey: "TEXTLIST_KEY") as? [String], list.count > 0 {
            dataList = list
        }
        if dataList.count == 0 {
            self.collectionView.isHidden = true
        }
        else {
            self.collectionView.adapterData = makeAdapterData()
            self.collectionView.reloadData()
        }
    }

    func makeAdapterData() -> UICollectionViewAdapterData {
        let adapterData = UICollectionViewAdapterData()
        let sectionInfo = UICollectionViewAdapterData.SectionInfo()

        for subData in dataList {
            let cellInfo = UICollectionViewAdapterData.CellInfo(contentObj: subData,
                                                                cellType: AddedTextCell.self) { [weak self]  (name, data) in
                guard let self = self else { return }
                print("\(name) data: \(data)")
                if name == AddedTextCell.SELECT_KEY, let data = data as? String {
                    self.completionClosure?(data)
                    self.pop()
                }
                else if name == AddedTextCell.REMOVE_KEY, let index = data as? Int {
                    self.dataList.remove(at: index)
                }
            }
            sectionInfo.cells.append(cellInfo)

        }
        adapterData.sectionList.append(sectionInfo)
        return adapterData
    }

    @IBAction func onAddText(_ sender: UIButton) {
        dataList.append(textView.text)
        textView.text = ""
        setAddTextButton(false)
    }

    func setAddTextButton(_ value: Bool) {
        if value {
            addTextButton.backgroundColor = .orange
            addTextButton.isEnabled = true
        }
        else {

            addTextButton.backgroundColor = .darkGray
            addTextButton.isEnabled = false
        }
    }

    @IBAction func onCloseButton(_ sender: Any) {
        pop()
    }

    func pop() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddTextViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, text.isValid {
            textViewPlaceholderLabel.isHidden = true
            setAddTextButton(true)
        }
        else {
            textViewPlaceholderLabel.isHidden = false
            setAddTextButton(false)
        }

        inputBoxView.heightConstraint = min(81, max(textView.contentSize.height, inputBoxView.heightDefaultConstraint)) // 3줄까지
    }
}



extension AddTextViewController: NavigationAnimatorAble {
    var pushAnimation: PushAnimator? {
        PushAnimator(animationType: .up)
    }

    var popAnimation: PopAnimator? {
        self.popAnimator
    }
}

extension AddTextViewController {
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

        if animationDuration > 0 {
            UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: UIView.AnimationOptions(rawValue: UInt(animationCurveOption.rawValue)), animations: {
                if keyboardEndFrame.origin.y < self.view.h {
                    self.bodyView.topConstraint = 20
                }
                else {
                    self.bodyView.topConstraint = self.bodyView.topDefaultConstraint
                }

                self.view.layoutIfNeeded()
            }) { finished in
            }
        }
        else {
            if keyboardEndFrame.origin.y < view.h {
                self.bodyView.topConstraint = 20
            }
            else {
                self.bodyView.topConstraint = self.bodyView.topDefaultConstraint
            }
        }


    }
}
