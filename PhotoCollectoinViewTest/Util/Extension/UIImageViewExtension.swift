//
//  UIImageViewExtension.swift
//  pkh0225
//
//  Created by pkh on 2021/07/11.
//

import Foundation
import  UIKit

extension UIImageView {
    private struct AssociatedKeys {
        static var imageDataTask: UInt8 = 0
    }

    private static var UrlToImageCache: NSCache<NSString, UIImage>?

    private var imageDataTask: URLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.imageDataTask) as? URLSessionDataTask
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.imageDataTask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setUrlImage(_ urlString: String?, backgroundColor: UIColor? = nil) {
        guard let urlString = urlString, urlString.isValid else { return }
        if let cachedImage = Self.UrlToImageCache?.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }

        self.backgroundColor = backgroundColor

        guard let url = URL(string: urlString) else { return }
        imageDataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            guard let self = self else { return }
            guard let data = data, let image = UIImage(data: data), error == nil else { return }

            self.imageDataTask = nil

            DispatchQueue.main.async {
                UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    self.image = image
                }, completion: nil)
            }

            if Self.UrlToImageCache == nil {
                Self.UrlToImageCache = NSCache<NSString, UIImage>()
                Self.UrlToImageCache?.countLimit = 100
            }
            Self.UrlToImageCache?.setObject(image, forKey: urlString as NSString)
        }

        imageDataTask?.resume()

    }
}
