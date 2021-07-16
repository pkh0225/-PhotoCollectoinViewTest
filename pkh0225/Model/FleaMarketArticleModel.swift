//
//  FleaMarketArticleModel.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import Foundation

class FleaMarketArticleModel {
    var title: String = ""
    var content: String = ""
    var price: Int = -1 {
        didSet {
            isFreePrice = price == 0
        }
    }
    var isFreePrice: Bool = false
    var isSuggestion: Bool = false
    var regionID: Int = 0
    var regionNsme: String = ""
    var categoryID: Int = 0
    var categoryName: String = ""
}
