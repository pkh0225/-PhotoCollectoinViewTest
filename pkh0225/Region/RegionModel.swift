//
//  RegionModel.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import Foundation

class RegionModel: CategoryCellProtocol {
    var title: String { regionName }
    var isSelected: Bool
    var id: Int
    var regionName: String


    init(id: Int, regionName: String, isSelected: Bool = false) {
        self.id = id
        self.regionName = regionName
        self.isSelected =  isSelected
    }
}
