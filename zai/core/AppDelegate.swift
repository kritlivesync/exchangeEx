//
//  AppDelegate.swift
//  zai
//
//  Created by Kyota Watanabe on 6/19/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import UIKit

import Firebase
import CoreData


protocol AppBackgroundDelegate {
    func applicationDidEnterBackground(_ application: UIApplication)
    func applicationDidBecomeActive(_ application: UIApplication)
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        self.notification = PromiseNotification()
        
        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: getGlobalConfig().appId)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.delegate?.applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.delegate?.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    var notification: PromiseNotification!
    var candleCharts: CandleChartContainer!
    let globalConfig = GlobalConfig()
    var account: Account?
    var resource = Resource()
    var delegate: AppBackgroundDelegate?
}

func setBackgroundDelegate(delegate: AppBackgroundDelegate) {
    let app = UIApplication.shared.delegate as! AppDelegate
    app.delegate = delegate
}

func getGlobalConfig() -> GlobalConfig {
    let app = UIApplication.shared.delegate as! AppDelegate
    return app.globalConfig
}

func getApp() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func getAccount() -> Account? {
    let app = UIApplication.shared.delegate as! AppDelegate
    return app.account
}

func createResource(exchangeName: String) -> Resource {
    switch exchangeName {
    case "Zaif":
        return ZaifResource()
    case "bitFlyer":
        return bitFlyerResource()
    default:
        return Resource()
    }
}

func createAdView(parent: UIViewController) -> GADBannerView {
    let admob = GADBannerView(adSize:kGADAdSizeBanner)
    var posY = parent.view.frame.size.height - admob.frame.height
    if let nabbar =  parent.navigationController?.navigationBar {
        posY -= nabbar.frame.size.height
    }
    if let tabar = parent.tabBarController?.tabBar {
        posY -= tabar.frame.size.height
    }
    admob.frame.origin = CGPoint(x: 0, y: posY)
    admob.frame.size = CGSize(width: parent.view.frame.width, height: admob.frame.height)
    admob.adUnitID = getGlobalConfig().unitId
    return admob
}

func getResource() -> Resource {
    let app = UIApplication.shared.delegate as! AppDelegate
    return app.resource
}

func getAppConfig() -> AppConfig {
    return getAccount()!.appConfig
}

func getAssetsConfig() -> AssetsConfig {
    return getAccount()!.assetsConfig
}

func getChartConfig() -> ChartConfig {
    return getAccount()!.chartConfig
}

func getBoardConfig() -> BoardConfig {
    return getAccount()!.boardConfig
}

func getPositionsConfig() -> PositionsConfig {
    return getAccount()!.positionsConfig
}

func getOrdersConfig() -> OrdersConfig {
    return getAccount()!.ordersConfig
}

