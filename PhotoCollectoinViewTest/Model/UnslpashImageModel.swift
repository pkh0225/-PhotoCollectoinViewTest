//
//  UnslpashImageModel.swift
//  pkh0225
//
//  Created by pkh on 2021/07/11.
//

import Foundation
import UIKit

class UnslpashImageModelList: PKHParser {
    var dataList = [UnslpashImageModel]()

    static func getResetData(pageIndex: Int, completion: @escaping (Self) -> Void) -> URLSessionDataTask? {
        return Request.getPhotos(pageIndex: pageIndex) { requestData, error in
            guard let requestData = requestData else { return }
            Self.initAsync(map: requestData, completionHandler: { (obj: Self) in
                completion(obj)
            })
        }
    }
}

class UnslpashSearchImageModelList: PKHParser {
    var total: Int = 0
    var total_pages: Int = 0
    var results = [UnslpashImageModel]()

    static func getResetData(query: String, pageIndex: Int, completion: @escaping (Self) -> Void) -> URLSessionDataTask? {
        return Request.getPhotos(query: query, pageIndex: pageIndex) { requestData, error in
            guard let requestData = requestData else { return }
            Self.initAsync(map: requestData, completionHandler: { (obj: Self) in
                completion(obj)
            })
        }
    }
}


class UnslpashImageModel: PKHParser {
    var id: String = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
    var color: String = ""
    var urls: UnslpashImageUrlModel?
    var user: UnslpashImageUserModel?

    var isSeleected: Bool = false
    var selectedCount: Int = 0
}

class UnslpashImageUrlModel: PKHParser {
    var raw: String = ""
    var full: String = ""
    var regular: String = ""
    var small: String = ""
    var thumb: String = ""
    /// 애니메이션용 임시 이미지
    var tempImage: UIImage?
}

class UnslpashImageUserModel: PKHParser {
    var id: String = ""
    var username: String = ""
    var profile_image: UnslpashImageProfilImageModel?
}

class UnslpashImageProfilImageModel: PKHParser {
    var small: String = ""
    var medium: String = ""
    var large: String = ""
}



