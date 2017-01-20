//
//  BoardSettingView.swift
//  zai
//
//  Created by 渡部郷太 on 1/18/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol BoardSettingViewDelegate {
    func changeUpdateInterval(setting: BoardSettingView)
}



class BoardSettingView : SettingView, VariableSettingCellDelegate {
    
    override init(section: Int, tableView: UITableView) {
        self._config = getBoardConfig()
        super.init(section: section, tableView: tableView)
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "variableSettingCell", for: indexPath) as! VariableSettingCell
            cell.nameLabel.text = "自動更新間隔"
            cell.valueLabel.text = self.config.autoUpdateInterval.string
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            return cell
        }
    }
    
    override func shouldHighlightRowAt(row: Int) -> Bool {
        switch row {
        case 0:
            return true
        default:
            return false
        }
    }
    
    func updateAutoUpdateInterval(tableView: UITableView, interval: UpdateInterval) {
        let index = IndexPath(row: 0, section: self.section)
        guard let cell = tableView.cellForRow(at: index) as? VariableSettingCell else {
            return
        }
        cell.valueLabel.text = interval.string
    }
    
    // VariableSettingCellDelegate
    func touchesEnded(name: String, value: String) {
        self.delegate?.changeUpdateInterval(setting: self)
    }
    
    // ChangeUpdateIntervalDelegate
    override func saved(interval: UpdateInterval) {
        self.updateAutoUpdateInterval(tableView: self.tableView, interval: interval)
    }
    
    override var sectionName: String {
        return "Board"
    }
    
    override var rowCount: Int {
        return 1
    }
    
    override var config: Config {
        return self._config
    }
    
    
    let _config: BoardConfig
    var delegate: BoardSettingViewDelegate?
}
