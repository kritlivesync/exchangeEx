//
//  SettingsViewController.swift
//  zai
//
//  Created by 渡部郷太 on 1/11/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol SettingProtocol {
    func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    
    var settingName: String { get }
    var settingCount: Int { get }
}

class SettingsViewController : UITableViewController, UserAccountSettingDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.tableView.tableFooterView = UIView()
        self.tableView.isScrollEnabled = false
        self.tableView.bounces = false
        
        self.tableView.register(UINib(nibName: "ReadOnlySettingCell", bundle: nil), forCellReuseIdentifier: "readOnlySettingCell")
        self.tableView.register(UINib(nibName: "ValueActionSettingCell", bundle: nil), forCellReuseIdentifier: "valueActionSettingCell")
        
        let account = getAccount()!
        let userSetting = UserAccountSettingView(account: account)
        userSetting.delegate = self
        self.settings[0] = userSetting
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.backgroundColor = UIColor.groupTableViewBackground
        label.font = label.font.withSize(12.0)
        label.text = self.settings[section]?.settingName
        return label
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let setting = self.settings[section] else {
            return 0
        }
        return setting.settingCount
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let setting = self.settings[indexPath.section] else {
            return tableView.dequeueReusableCell(withIdentifier: "readOnlySettingCell", for: indexPath) as! ReadOnlySettingCell
        }
        return setting.getCell(tableView: tableView, indexPath: indexPath)
    }
    
    // UserAccountSettingDelegate
    func loggedOut(userId: String) {
        let storyboard: UIStoryboard = self.storyboard!
        let login = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        self.present(login, animated: true, completion: nil)
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var settings = [Int:SettingProtocol]()
}
