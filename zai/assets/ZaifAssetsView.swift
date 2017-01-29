//
//  ZaifAssetsView.swift
//  zai
//
//  Created by Kyota Watanabe on 1/20/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


protocol ZaifAssetsDelegate {
    func updatedMarketCaptaliation(jpy: Int)
}


class ZaifAssetsView : SectionView, FundDelegate {
    
    init(exchange: ZaifExchange, section: Int, tableView: UITableView) {
        self.exchange = exchange
        super.init(section: section, tableView: tableView)
    }
    
    func startWatch() {
        self.fund = Fund(api: exchange.api)
        let config = getAssetsConfig()
        self.fund.monitoringInterval = config.assetUpdateIntervalType
        self.fund.delegate = self
    }
    
    func stopWatch() {
        self.fund.delegate = nil
        self.fund = nil
    }
    
    override func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            cell.nameLabel.text = "時価評価額"
            cell.nameLabel.font = cell.nameLabel.font.withSize(24.0)
            cell.valueLabel.font = cell.valueLabel.font.withSize(24.0)
            guard let fund = self.marketCapitalization else {
                cell.valueLabel.text = "-"
                return cell
            }
            cell.valueLabel.text = formatValue(fund)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            cell.nameLabel.text = "JPY"
            cell.nameLabel.font = cell.nameLabel.font.withSize(24.0)
            cell.valueLabel.font = cell.valueLabel.font.withSize(24.0)
            guard let fund = self.jpyFund else {
                cell.valueLabel.text = "-"
                return cell
            }
            cell.valueLabel.text = formatValue(fund)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
            cell.nameLabel.text = "BTC"
            cell.nameLabel.font = cell.nameLabel.font.withSize(24.0)
            cell.valueLabel.font = cell.valueLabel.font.withSize(24.0)
            guard let fund = self.btcFund else {
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
    
    override func shouldHighlightRowAt(row: Int) -> Bool {
        return false
    }
    
    override var sectionName: String {
        return "Zaif"
    }
    
    override var rowCount: Int {
        return 3
    }
    
    // MonitorableDelegate
    func getDelegateName() -> String {
        return "ZaifAssetsDelegate"
    }
    
    // FundDelegate
    func recievedMarketCapitalization(jpy: Int) {
        self.marketCapitalization = jpy
        let index = IndexPath(row: 0, section: self.section)
        guard let cell = tableView.cellForRow(at: index) as? ReadOnlySettingCell else {
            return
        }
        DispatchQueue.main.async {
            cell.valueLabel.text = formatValue(jpy)
        }
        self.delegate?.updatedMarketCaptaliation(jpy: jpy)
    }
    
    func recievedJpyFund(jpy: Int) {
        self.jpyFund = jpy
        let index = IndexPath(row: 1, section: self.section)
        guard let cell = tableView.cellForRow(at: index) as? ReadOnlySettingCell else {
            return
        }
        DispatchQueue.main.async {
            cell.valueLabel.text = formatValue(jpy)
        }
    }
    
    func recievedBtcFund(btc: Double) {
        self.btcFund = btc
        let index = IndexPath(row: 2, section: self.section)
        guard let cell = tableView.cellForRow(at: index) as? ReadOnlySettingCell else {
            return
        }
        DispatchQueue.main.async {
            cell.valueLabel.text = formatValue(btc)
        }
    }
    
    var marketCapitalization: Int?
    var jpyFund: Int?
    var btcFund: Double?
    var exchange: ZaifExchange!
    var fund: Fund!
    var delegate: ZaifAssetsDelegate?
}
