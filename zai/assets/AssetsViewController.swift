//
//  AssetsViewController.swift
//  zai
//
//  Created by 渡部郷太 on 12/13/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import UIKit

class AssetsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
    
        self.assetsView = AssetsView(view: self.assetsTableView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.assetsView.startWatch()
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
