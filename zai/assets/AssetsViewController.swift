//
//  AssetsViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 12/13/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import UIKit

class AssetsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.assetsView = AssetsView(view: self.assetsTableView)
        self.assetsView.startWatch()
        
        if let trader = getAccount()?.activeExchange.trader {
            trader.fund.delegate = nil
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.assetsView.stopWatch()
    }
    
    @IBAction func pushSettingsButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let settings = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! UINavigationController
        self.present(settings, animated: true, completion: nil)
    }

    var assetsView: AssetsView!
    
    @IBOutlet weak var assetsTableView: UITableView!
}
