//
//  SectionView.swift
//  zai
//
//  Created by Kyota Watanabe on 1/20/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


class SectionView {
    init(section: Int, tableView: UITableView) {
        self.section = section
        self.tableView = tableView
    }
    
    func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell { return UITableViewCell() }
    func getRowHeight(row: Int) -> Double { return 44.0 }
    
    func shouldHighlightRowAt(row: Int) -> Bool { return false}
    
    var sectionName: String { get { return "" } }
    var rowCount: Int { get { return 0 } }
    let section: Int
    let tableView: UITableView
}
