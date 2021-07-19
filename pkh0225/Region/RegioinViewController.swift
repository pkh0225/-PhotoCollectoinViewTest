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

    lazy var region: RegionModel = RegionModel(id: 1, regionName: "역삼동", townCount: 1)

    var completionClosure: ((RegionModel) -> Void)? = nil
    var selectedId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        titleBarViewController?.isBackButton = true
        titleBarViewController?.delegate = self
        twonCountLabe.attributedText = "근처 동네 \(region.townCount)개".underLine()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        slider.addGestureRecognizer(tapGesture)

        view.layoutIfNeeded()
        sliderBarView1.leadingConstraint = (sliderBackView.w / 3 ) + 2
        sliderBarView2.leadingConstraint = sliderBarView1.leadingConstraint * 2
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
        var count: Int = 0
        switch setValue {
        case 1...5:
            value = 0
            count = 1
        case 6...15:
            value = 11
            count = 11
        case 16...25:
            value = 21
            count = 15
        case 26...30:
            value = 30
            count = 32
        default:
            print("\(slider.value)")
        }
        sliderAnimation(value: value)
        region.townCount = count
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

extension RegioinViewController: TitleBarViewControllerDelegate {
    func onBackButton() {
        completionClosure?(region)
    }
}
