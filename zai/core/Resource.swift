//
//  Resource.swift
//  zai
//
//  Created by Kyota Watanabe on 1/28/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation

import ZaifSwift
import bFSwift


class Resource {
    static var invalidUserIdOrPassword: String {
        return NSLocalizedString("invalidUserIdOrPassword", comment: "")
    }
    static var invalidPassword: String {
        return NSLocalizedString("invalidPassword", comment: "")
    }
    static var passwordSameAsCurrent: String {
        return NSLocalizedString("passwordSameAsCurrent", comment: "")
    }
    static var invalidUserIdLength: String {
        return String(format: NSLocalizedString("invalidUserIdLength", comment: ""), minUserIdLength, maxUserIdLength)
    }
    static var userIdAlreadyUsed: String {
        return NSLocalizedString("userIdAlreadyUsed", comment: "")
    }
    static var passwordAgainNotMatch: String {
        return NSLocalizedString("passwordAgainNotMatch", comment: "")
    }
    static var invalidPasswordLength: String {
        return String(format: NSLocalizedString("invalidPasswordLength", comment: ""), minPasswordLength, maxPasswordLength)
    }
    static var accountCreationFailed: String {
        return NSLocalizedString("accountCreationFailed", comment: "")
    }
    static var networkConnectionError: String {
        return NSLocalizedString("networkConnectionError", comment: "")
    }
    static var unknownError: String {
        return NSLocalizedString("unknownError", comment: "")
    }
    var apiKeyNoPermission: String {
        return NSLocalizedString("apiKeyNoPermission", comment: "")
    }
    var apiKeyNonceNotIncremented: String {
        return NSLocalizedString("apiKeyNonceNotIncremented", comment: "")
    }
    var invalidApiKey: String {
        return NSLocalizedString("invalidApiKey", comment: "")
    }
    var invalidApiKeyRestricted: String {
        return NSLocalizedString("invalidApiKeyRestricted", comment: "")
    }
    static func insufficientAmount(minAmount: Double, currency: ApiCurrency) -> String {
        return String(format: NSLocalizedString("insufficientAmount", comment: ""), minAmount, currency.label)
    }
    static var insufficientFunds: String {
        return NSLocalizedString("insufficientFunds", comment: "")
    }

    static var noPositionsToUnwind: String {
        return NSLocalizedString("noPositionsToUnwind", comment: "")
    }
    
    static var positionAddMessage: String {
        return NSLocalizedString("positionAddMessage", comment: "")
    }
}

class LabelResource {
    static var loginViewTitle: String {
        return "exchangeEx"
    }
    static var loginUserIdPlaceholder: String {
        return NSLocalizedString("loginUserIdPlaceholder", comment: "")
    }
    static var loginPasswordPlaceholder: String {
        return NSLocalizedString("loginPasswordPlaceholder", comment: "")
    }
    static var login: String {
        return NSLocalizedString("login", comment: "")
    }
    static var createNewAccount: String {
        return NSLocalizedString("createNewAccount", comment: "")
    }
    static var newAccountViewTitle: String {
        return NSLocalizedString("newAccountViewTitle", comment: "")
    }
    static var cancel: String {
        return NSLocalizedString("cancel", comment: "")
    }
    static var save: String {
        return NSLocalizedString("save", comment: "")
    }
    static var assetsViewTitle: String {
        return NSLocalizedString("assetsViewTitle", comment: "")
    }
    static var totalAssets: String {
        return NSLocalizedString("totalAssets", comment: "")
    }
    static var marketCapital: String {
        return NSLocalizedString("marketCapital", comment: "")
    }
    static var chartViewTitle: String {
        return NSLocalizedString("chartViewTitle", comment: "")
    }
    static var funds: String {
        return NSLocalizedString("funds", comment: "")
    }
    static func candleChart(interval: Int) -> String {
        return String(format: NSLocalizedString("candleChart", comment: ""), interval)
    }
    static var positionStateOpen: String {
        return NSLocalizedString("positionStateOpen", comment: "")
    }
    static var positionStateClosed: String {
        return NSLocalizedString("positionStateClosed", comment: "")
    }
    static var positionStateUnwinding: String {
        return NSLocalizedString("positionStateUnwinding", comment: "")
    }
    static var positionStateOpening: String {
        return NSLocalizedString("positionStateOpening", comment: "")
    }
    static var positionStateWaiting: String {
        return NSLocalizedString("positionStateWaiting", comment: "")
    }
    static var positionStateDeleted: String {
        return NSLocalizedString("positionStateDeleted", comment: "")
    }
    static var positionStatePartial: String {
        return NSLocalizedString("positionStatePartial", comment: "")
    }
    static var positionAddViewTitle: String {
        return NSLocalizedString("positionAddViewTitle", comment: "")
    }
    static var positionEditViewTitle: String {
        return NSLocalizedString("positionEditViewTitle", comment: "")
    }
    static var price: String {
        return NSLocalizedString("price", comment: "")
    }
    static var amount: String {
        return NSLocalizedString("amount", comment: "")
    }
    static var add: String {
        return NSLocalizedString("add", comment: "")
    }
    static var delete: String {
        return NSLocalizedString("delete", comment: "")
    }
    static var unwind: String {
        return NSLocalizedString("unwind", comment: "")
    }
    static var ordersViewTitle: String {
        return NSLocalizedString("ordersViewTitle", comment: "")
    }
    static var orderDate: String {
        return NSLocalizedString("orderDate", comment: "")
    }
    static var buy: String {
        return NSLocalizedString("buy", comment: "")
    }
    static var sell: String {
        return NSLocalizedString("sell", comment: "")
    }
    static var make: String {
        return NSLocalizedString("make", comment: "")
    }
    static var bestBid: String {
        return NSLocalizedString("bestBid", comment: "")
    }
    static var bestAsk: String {
        return NSLocalizedString("bestAsk", comment: "")
    }
    static var boardViewTitle: String {
        return NSLocalizedString("boardViewTitle", comment: "")
    }
    static var quotePrice: String {
        return NSLocalizedString("quotePrice", comment: "")
    }
    static var quoteAmount: String {
        return NSLocalizedString("quoteAmount", comment: "")
    }
    static var positionsViewTitle: String {
        return NSLocalizedString("positionsViewTitle", comment: "")
    }
    static var acquisitionCost: String {
        return NSLocalizedString("acquisitionCost", comment: "")
    }
    static var amountRest: String {
        return NSLocalizedString("amountRest", comment: "")
    }
    static var profitLoss: String {
        return NSLocalizedString("profitLoss", comment: "")
    }
    static var state: String {
        return NSLocalizedString("state", comment: "")
    }
    static var totalProfitLoss: String {
        return NSLocalizedString("totalProfitLoss", comment: "")
    }
    static var priceAverage: String {
        return NSLocalizedString("priceAverage", comment: "")
    }
    static var btcFunds: String {
        return NSLocalizedString("btcFunds", comment: "")
    }
    static var ignoreApiError: String {
        return NSLocalizedString("ignoreApiError", comment: "")
    }
    static var userIdPlacecholder: String {
        return NSLocalizedString("userIdPlacecholder", comment: "")
    }
    static var passwordPlaceholder: String {
        return NSLocalizedString("passwordPlaceholder", comment: "")
    }
    static var passwordAgainPlaceholder: String {
        return NSLocalizedString("passwordAgainPlaceholder", comment: "")
    }
    static var required: String {
        return NSLocalizedString("required", comment: "")
    }
    static var apiKeyPlaceholder: String {
        return NSLocalizedString("apiKeyPlaceholder", comment: "")
    }
    static var secretKeyPlaceholder: String {
        return NSLocalizedString("secretKeyPlaceholder", comment: "")
    }
    static var zaifApiKeySection: String {
        return NSLocalizedString("zaifApiKeySection", comment: "")
    }
    static var biyFlyerApiKeySection: String {
        return NSLocalizedString("biyFlyerApiKeySection", comment: "")
    }
    
    static var logout: String {
        return NSLocalizedString("logout", comment: "")
    }
    static var password: String {
        return NSLocalizedString("password", comment: "")
    }
    static var exchange: String {
        return NSLocalizedString("exchange", comment: "")
    }
    static var currencyPair: String {
        return NSLocalizedString("currencyPair", comment: "")
    }
    static var apiKey: String {
        return NSLocalizedString("apiKey", comment: "")
    }
    static var buyAmountLimit: String {
        return NSLocalizedString("buyAmountLimit", comment: "")
    }
    static var unwindingRule: String {
        return NSLocalizedString("unwindingRule", comment: "")
    }
    static var updateInterval: String {
        return NSLocalizedString("updateInterval", comment: "")
    }
    static var back: String {
        return NSLocalizedString("back", comment: "")
    }
    static var settings: String {
        return NSLocalizedString("settings", comment: "")
    }
    static var changePassword: String {
        return NSLocalizedString("changePassword", comment: "")
    }
    static var currentPasswordPlaceholder: String {
        return NSLocalizedString("currentPasswordPlaceholder", comment: "")
    }
    static var newPasswordPlaceholder: String {
        return NSLocalizedString("newPasswordPlaceholder", comment: "")
    }
    static var changeExchange: String {
        return NSLocalizedString("changeExchange", comment: "")
    }
    static var changeZaifApiKey: String {
        return NSLocalizedString("changeZaifApiKey", comment: "")
    }
    static var changebitFlyerApiKey: String {
        return NSLocalizedString("changebitFlyerApiKey", comment: "")
    }
    static var mostProfitPosition: String {
        return NSLocalizedString("mostProfitPosition", comment: "")
    }
    static var mostLossPosition: String {
        return NSLocalizedString("mostLossPosition", comment: "")
    }
    static var mostNewPosition: String {
        return NSLocalizedString("mostNewPosition", comment: "")
    }
    static var mostOldPosition: String {
        return NSLocalizedString("mostOldPosition", comment: "")
    }
    static var oneSecond: String {
        return NSLocalizedString("oneSecond", comment: "")
    }
    static var twoSeconds: String {
        return NSLocalizedString("twoSeconds", comment: "")
    }
    static var threeSeconds: String {
        return NSLocalizedString("threeSeconds", comment: "")
    }
    static var fourSeconds: String {
        return NSLocalizedString("fourSeconds", comment: "")
    }
    static var fiveSeconds: String {
        return NSLocalizedString("fiveSeconds", comment: "")
    }
    static var tenSeconds: String {
        return NSLocalizedString("tenSeconds", comment: "")
    }
    static var thirtySeconds: String {
        return NSLocalizedString("thirtySeconds", comment: "")
    }
    static var oneMinute: String {
        return NSLocalizedString("oneMinute", comment: "")
    }
    static var realtime: String {
        return NSLocalizedString("realtime", comment: "")
    }
    static var technicalNone: String {
        return NSLocalizedString("technicalNone", comment: "")
    }
    static var technicalBollingerBand: String {
        return NSLocalizedString("technicalBollingerBand", comment: "")
    }
    static var technicalSma5: String {
        return NSLocalizedString("technicalSma5", comment: "")
    }
    static var technicalSma25: String {
        return NSLocalizedString("technicalSma25", comment: "")
    }
    
    static var orderTimeoutError: String {
        return NSLocalizedString("orderTimeoutError", comment: "")
    }
    static var invalidOrderError: String {
        return NSLocalizedString("invalidOrderError", comment: "")
    }
    static var invalidApiKeyError: String {
        return NSLocalizedString("invalidApiKeyError", comment: "")
    }
    static var apiKeyNoPermissionError: String {
        return NSLocalizedString("apiKeyNoPermissionError", comment: "")
    }
    static var loginError: String {
        return NSLocalizedString("loginError", comment: "")
    }
    static var nonceNotIncrementedError: String {
        return NSLocalizedString("nonceNotIncrementedError", comment: "")
    }
    static var networkError: String {
        return NSLocalizedString("networkError", comment: "")
    }
    static var unknownError: String {
        return NSLocalizedString("unknownError", comment: "")
    }
}

class ZaifResource : Resource {
    
    override var apiKeyNoPermission: String {
        return NSLocalizedString("apiKeyNoPermission", comment: "")
    }
    override var apiKeyNonceNotIncremented: String {
        return NSLocalizedString("apiKeyNonceNotIncremented", comment: "")
    }
    override var invalidApiKey: String {
        return NSLocalizedString("invalidApiKey", comment: "")
    }

}

class bitFlyerResource : Resource {
    override var apiKeyNoPermission: String {
        return NSLocalizedString("apiKeyNoPermission", comment: "")
    }

    override var invalidApiKey: String {
        return NSLocalizedString("invalidApiKey", comment: "")
    }
}
