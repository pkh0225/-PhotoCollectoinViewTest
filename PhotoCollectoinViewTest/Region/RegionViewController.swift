//
//  RegioinViewController.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import UIKit

class RegionViewController: BaseTitleBarController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var sliderBarView1: UIView!
    @IBOutlet weak var sliderBarView2: UIView!
    @IBOutlet weak var twonCountLabe: UILabel!
    @IBOutlet weak var sliderBackView: UIView!

    private lazy var accessQueue = DispatchQueue(label: "accessQueue_\(self.className)", qos: .userInitiated, attributes: .concurrent)

    var popAnimator: PopAnimator?
    var region: RegionModel?
    var completionClosure: ((RegionModel?) -> Void)? = nil
    var selectedId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        titleBarViewController?.isSubmitButton = true
        titleBarViewController?.submitTitle = "X"
        titleBarViewController?.delegate = self

        self.popAnimator = PopAnimator(animationType: .up, tagetViewController: self, tagetView: self.view)
        self.popAnimator?.setAnimationCompletion { [weak self] in
            guard let self = self else { return }
            self.onSubmitButton()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        slider.addGestureRecognizer(tapGesture)

        view.layoutIfNeeded()
        sliderBarView1.leadingConstraint = (sliderBackView.w / 3 ) + 2
        sliderBarView2.leadingConstraint = sliderBarView1.leadingConstraint * 2

        if self.region == nil {
            region = RegionModel(id: 1, regionName: "역삼동", townCount: 12, level: 2)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.sliderSetValue(CGFloat((self.region?.level ?? 0) * 10))
        }
    }


    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            let x: CGFloat = recognizer.location(in: slider).x
//            vaue : slider.maximumValue = x : slider.w
            var value = CGFloat(slider.maximumValue) * x / slider.w

            value = max(CGFloat(slider.minimumValue), min(value, CGFloat(slider.maximumValue)))
            sliderSetValue(value)
        }

    }

    func sliderSetValue(_ setValue: CGFloat) {
        var value: CGFloat = 0
        var count: Int = 1
        var level : Int = 0
        switch setValue {
        case 1...5:
            value = 0
            count = 1
            level = 0
        case 6...15:
            value = 11
            count = 11
            level = 1
        case 16...25:
            value = 21
            count = 15
            level = 2
        case 26...30:
            value = 30
            count = 32
            level = 3
        default:
            print("\(slider.value)")
        }
        sliderAnimation(value: value)
        region?.townCount = count
        region?.level = level
        twonCountLabe.attributedText = "근처 동네 \(count)개".underLine()
    }

    func sliderAnimation(value: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.slider.setValue(Float(value), animated: true)
            self.onSliderValueChange(self.slider)
        }, completion: { _ in
        })
    }

    @IBAction func onSliderTouchUp(_ sender: UISlider) {
        sliderSetValue(CGFloat(sender.value))
    }

    @IBAction func onSliderValueChange(_ sender: UISlider) {
        print("slider: \(sender.value)")
        var remain = CGFloat(sender.value.truncatingRemainder(dividingBy: 10.0))
        remain = remain == 0 ? 10 : remain
        let raito: CGFloat = 1.0 - (remain / 10.0)
        switch sender.value {
        case 1...10:
            image1.alpha = raito
            image2.alpha = 1
            image3.alpha = 1
        case 11...20:
            image1.alpha = 0
            image2.alpha = raito
            image3.alpha = 1
        case 21...30:
            image1.alpha = 0
            image2.alpha = 0
            image3.alpha = raito
        default:
            print("\(sender.value)")
        }
    }
}

extension RegionViewController: TitleBarViewControllerDelegate {
    func onSubmitButton() {
        completionClosure?(region)
        self.navigationController?.popViewController(animated: true)
    }
}

extension RegionViewController: NavigationAnimatorAble {
    var pushAnimation: PushAnimator? {
        PushAnimator(animationType: .up)
    }

    var popAnimation: PopAnimator? {
        self.popAnimator
    }
}
