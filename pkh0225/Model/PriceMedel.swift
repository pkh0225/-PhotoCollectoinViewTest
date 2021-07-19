//
//  PriceMedel.swift
//  pkh0225
//
//  Created by pkh on 2021/07/19.
//

import Foundation

class PriceModel {
    var price: Int = -1 {
        didSet {
            isFreePrice = price == 0
        }
    }
    var isFreePrice: Bool = false
    var isSuggestion: Bool = false
}
