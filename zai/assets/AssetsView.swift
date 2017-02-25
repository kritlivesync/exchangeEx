//
//  AssetsView.swift
//  zai
//
//  Created by Kyota Watanabe on 1/20/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


class AssetsView : NSObject, UITableViewDelegate, UITableViewDataSource, ExchangeAssetsDelegate {
    
    init(view: UITableView) {
        self.view = view
        self.view.tableFooterView = UIView()
        self.view.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0);
        self.view.separatorColor = UIColor.clear
        self.sectionViews = [SectionView]()
        
        super.init()
        
        self.view.register(UINib(nibName: "ReadOnlySettingCell", bundle: nil), forCellReuseIdentifier: "readOnlySettingCell")
        self.view.delegate = self
        self.view.dataSource = self
        
        self.summaryView = AssetsSummaryView(section: self.sectionViews.count, tableView: self.view)
        self.sectionViews.append(self.summaryView!)
        
        let account = getAccount()!
        if let bitFlyer = account.getExchange(exchangeName: "bitFlyer") {
            self.bitFlyerAssets = ExchangeAssetsView(exchange: bitFlyer, section: self.sectionViews.count, tableView: self.view)
            self.bitFlyerAssets?.delegate = self
            self.sectionViews.append(self.bitFlyerAssets!)
        }
        if let zaif = account.getExchange(exchangeName: "Zaif") {
            self.zaifAssets = ExchangeAssetsView(exchange: zaif, section: self.sectionViews.count, tableView: self.view)
            self.zaifAssets?.delegate = self
            self.sectionViews.append(self.zaifAssets!)
        }
    }

    func startWatch() {
        self.zaifAssets?.startWatch()
        self.bitFlyerAssets?.startWatch()
    }
    
    func stopWatch() {
        self.zaifAssets?.stopWatch()
        self.bitFlyerAssets?.stopWatch()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionViews.count
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        } else {
            return 28.0
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 20.0, y: 0.0, width: 100.0, height: 28.0))
        label.textColor = UIColor.gray
        label.font = label.font.withSize(17.0)
        label.text = self.sectionViews[section].sectionName
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 28.0))
        view.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(label)
        return view
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < self.sectionViews.count else {
            return 0
        }
        return self.sectionViews[section].rowCount
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        guard section < self.sectionViews.count else {
            return 0.0
        }
        let height = self.sectionViews[indexPath.section].getRowHeight(row: indexPath.row)
        return CGFloat(height)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        guard section < self.sectionViews.count else {
            return tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
        }
        return self.sectionViews[section].getCell(tableView: tableView, indexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        guard section < self.sectionViews.count else {
            return false
        }
        return self.sectionViews[section].shouldHighlightRowAt(row: indexPath.row)
    }

    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    // ExchangeAssetsDelegate
    func updatedMarketCaptaliation(jpy: Int) {
        var sum = 0
        if let jpy = self.zaifAssets?.marketCapitalization {
            sum += jpy
        }
        if let jpy = self.bitFlyerAssets?.marketCapitalization {
            sum += jpy
        }
        self.summaryView?.updateMarketCapitalization(value: sum)
    }
    
    fileprivate let view: UITableView
    fileprivate var summaryView: AssetsSummaryView?
    fileprivate var zaifAssets: ExchangeAssetsView?
    fileprivate var bitFlyerAssets: ExchangeAssetsView?
    fileprivate var sectionViews: [SectionView]
}
