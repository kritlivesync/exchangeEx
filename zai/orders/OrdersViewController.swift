//
//  OrdersViewController.swift
//  zai
//
//  Created by 渡部郷太 on 12/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class OrdersViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.ordersHeadersLabel.backgroundColor = Color.keyColor2
        
        let account = getAccount()
        
        self.orderListView = OrderListView(view: self.orderTableView, trader: account!.activeExchange.trader)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.orderListView.startWatch()
        self.orderListView.reloadData()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.orderListView.stopWatch()
    }
    
    @IBAction func pushSettingsButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let settings = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! UINavigationController
        self.present(settings, animated: true, completion: nil)
    }
    
    var account: Account?
    var orderListView: OrderListView!
    
    @IBOutlet weak var ordersHeadersLabel: UILabel!
    @IBOutlet weak var orderTableView: UITableView!
}
