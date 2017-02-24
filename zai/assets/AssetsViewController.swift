//
//  AssetsViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 12/13/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import UIKit

import GoogleMobileAds


class AssetsViewController: UIViewController, AppBackgroundDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        let image = self.navigationController?.navigationBar.items?[0].leftBarButtonItem?.image
        self.navigationController?.navigationBar.items?[0].leftBarButtonItem?.image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let admob = createAdView(parent: self)
        admob.rootViewController = self
        admob.load(GADRequest())
        self.view.addSubview(admob)
        
        self.assetsView = AssetsView(view: self.assetsTableView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.start()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stop()
    }
    
    fileprivate func start() {
        setBackgroundDelegate(delegate: self)
        self.assetsView.startWatch()
        
        if let trader = getAccount()?.activeExchange.trader {
            trader.stopWatch()
        }
    }
    
    fileprivate func stop() {
        self.assetsView.stopWatch()
    }
    
    // AppBackgroundDelegate
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.start()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.stop()
    }
    
    @IBAction func pushSettingsButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let settings = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! UINavigationController
        self.present(settings, animated: true, completion: nil)
    }

    var assetsView: AssetsView!
    
    @IBOutlet weak var assetsTableView: UITableView!
}
