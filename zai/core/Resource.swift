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
}

class LabelResource {
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
    static var delete: String {
        return NSLocalizedString("delete", comment: "")
    }
    static var unwind: String {
        return NSLocalizedString("unwind", comment: "")
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
