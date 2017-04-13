//
//  NewAccountViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 8/24/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit

import ZaifSwift


class NewAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        self.navigationController?.navigationBar.items?[0].title = LabelResource.newAccountViewTitle
        self.navigationController?.navigationBar.items?[0].leftBarButtonItem?.title = LabelResource.cancel
        self.navigationController?.navigationBar.items?[0].rightBarButtonItem?.title = LabelResource.save
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "TextSettingCell", bundle: nil), forCellReuseIdentifier: "textSettingCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.saveButton.tintColor = Color.antiKeyColor
        self.cancelButton.tintColor = Color.antiKeyColor
        let backButtonItem = UIBarButtonItem(title: LabelResource.login, style: .plain, target: nil, action: nil)
        backButtonItem.tintColor = Color.antiKeyColor
        self.navigationItem.backBarButtonItem = backButtonItem
        
        self.newAccountView = NewAccountView(section: 0, tableView: self.tableView)
        self.newBitFlyerAccountView = NewBitFlyerAccount(section: 1, tableView: self.tableView)
        self.newZaifAccountView = NewZaifAccountView(section: 2, tableView: self.tableView)
        
        self.sectionViews.append(self.newAccountView)
        self.sectionViews.append(self.newBitFlyerAccountView)
        self.sectionViews.append(self.newZaifAccountView)

        self.tableView.reloadData()
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
        let label = UILabel(frame: CGRect(x: 15.0, y: 0.0, width: 300.0, height: 28.0))
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
            return UITableViewCell()
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
    
    @IBAction func pushSaveButton(_ sender: Any) {
        if self.activeIndicator.isAnimating {
            return
        }
        self.activeIndicator.startAnimating()
        
        if let err = self.newAccountView.validate() {
            self.activeIndicator.stopAnimating()
            self.showError(error: err)
            return
        }
        
        self.newBitFlyerAccountView.validate() { err in
            self.activeIndicator.stopAnimating()
            if err != nil {
                self.showWarning(error: err!) { _ in
                    self.activeIndicator.startAnimating()
                    self.newZaifAccountView.validate() { (err, nonce) in
                        self.zaifApiNonce = nonce
                        self.activeIndicator.stopAnimating()
                        if err != nil {
                            self.showWarning(error: err!) { _ in
                                self.performSegue(withIdentifier: "unwindWithSaveSegue", sender: self)
                            }
                        } else {
                            self.performSegue(withIdentifier: "unwindWithSaveSegue", sender: self)
                        }
                    }
                }
            } else {
                self.activeIndicator.startAnimating()
                self.newZaifAccountView.validate() { (err, nonce) in
                    self.zaifApiNonce = nonce
                    self.activeIndicator.stopAnimating()
                    if err != nil {
                        self.showWarning(error: err!) { _ in
                            self.performSegue(withIdentifier: "unwindWithSaveSegue", sender: self)
                        }
                    } else {
                        self.performSegue(withIdentifier: "unwindWithSaveSegue", sender: self)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifer = segue.identifier {
            if identifer == "unwindToLoginSegue" {
                // cancelled
                return
            }
        }
        
        let userId = self.newAccountView.getUserId()
        let password = self.newAccountView.getPassword()
        
        let repository = AccountRepository.getInstance()
        guard let account = repository.create(userId, password: password) else {
            self.showError(error: ZaiError(errorType: .UNKNOWN_ERROR, message: Resource.accountCreationFailed))
            return
        }
        
        let bitFLyerApiKey = self.newBitFlyerAccountView.getApiKey()
        let bitFlyerSecretKey = self.newBitFlyerAccountView.getSecretKey()
        guard let _ = repository.createBitFlyerExchange(account: account, apiKey: bitFLyerApiKey, secretKey: bitFlyerSecretKey) else {
            repository.delete(account)
            self.showError(error: ZaiError(errorType: .UNKNOWN_ERROR, message: Resource.accountCreationFailed))
            return
        }
        
        let zaifApiKey = self.newZaifAccountView.getApiKey()
        let zaifSecretKey = self.newZaifAccountView.getSecretKey()
        guard let _ = repository.createZaifExchange(account: account, apiKey: zaifApiKey, secretKey: zaifSecretKey, nonce: self.zaifApiNonce) else {
            repository.delete(account)
            self.showError(error: ZaiError(errorType: .UNKNOWN_ERROR, message: Resource.accountCreationFailed))
            return
        }
        
        let config = getGlobalConfig()
        config.previousUserId = userId
        _ = config.save()
    }

    fileprivate func showError(error: ZaiError) {
        let errorView = createErrorModal(title: error.errorType.toString(), message: error.message)
        self.present(errorView, animated: false, completion: nil)
    }
    
    fileprivate func showWarning(error: ZaiError, handler: @escaping ((UIAlertAction) -> Void)) {
        let wariningView = createWarningModal(title: error.errorType.toString(), message: error.message, continueLabel: LabelResource.ignoreApiError, handler: handler)
        DispatchQueue.main.async {
            self.present(wariningView, animated: false, completion: nil)
        }
    }

    var zaifApiNonce: Int64 = 0
    fileprivate var newAccountView: NewAccountView!
    fileprivate var newZaifAccountView: NewZaifAccountView!
    fileprivate var newBitFlyerAccountView: NewBitFlyerAccount!
    fileprivate var sectionViews: [SectionView] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!

    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
}
