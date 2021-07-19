//
//  CategoryModel.swift
//  pkh0225
//
//  Created by pkh on 2021/07/15.
//

import Foundation

class CategoryModel: CategoryCellProtocol {
    var title: String { categoryName }
    var isSelected: Bool

    var id: Int
    var categoryName: String

    init(id: Int, categoryName: String, isSelected: Bool = false) {
        self.id = id
        self.categoryName = categoryName
        self.isSelected = isSelected
    }
}
