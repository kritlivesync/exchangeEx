//
//  AssetsSummaryView.swift
//  zai
//
//  Created by 渡部郷太 on 1/20/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class AssetsSummaryView : SectionView {
    
    override init(section: Int, tableView: UITableView) {
        super.init(section: section, tableView: tableView)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            cell.nameLabel.text = "総資産"
            cell.nameLabel.font = cell.nameLabel.font.withSize(32.0)
            cell.valueLabel.font = cell.valueLabel.font.withSize(32.0)
            guard let fund = self.marketCapitalization else {
                cell.valueLabel.text = "-"
                return cell
            }
            cell.valueLabel.text = formatValue(fund)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            return cell
        }
    }
    
    override func getRowHeight(row: Int) -> Double {
        return 88.0
    }
    
    override func shouldHighlightRowAt(row: Int) -> Bool {
        return false
    }

    func updateMarketCapitalization(value: Int) {
        self.marketCapitalization = value
        let index = IndexPath(row: 0, section: self.section)
        guard let cell = tableView.cellForRow(at: index) as? ReadOnlySettingCell else {
            return
        }
        DispatchQueue.main.async {
            cell.valueLabel.text = formatValue(value)
        }
    }
    
    override var sectionName: String {
        return ""
    }
    
    override var rowCount: Int {
        return 1
    }
    
    var marketCapitalization: Int?
}
