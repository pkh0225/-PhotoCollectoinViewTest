//
//  RegionModel.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import Foundation

class RegionModel {
    var id: Int
    var regionName: String
    var townCount: Int

    init(id: Int, regionName: String, townCount: Int = 1) {
        self.id = id
        self.regionName = regionName
        self.townCount = townCount
    }
}
