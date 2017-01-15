//
//  Error.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


public enum ZaiErrorType : Error {
    case ZAIF_API_ERROR
    case INVALID_ORDER
    case INVALID_API_KEYS
    case INVALID_API_KEYS_NO_PERMISSION
    case INVALID_ACCOUNT_INFO
    case ZAIF_CONNECTION_ERROR
    case ORDER_TIMEOUT
    case INVALID_POSITION
    case UNKNOWN_ERROR
    
    func toString() -> String {
        switch self {
        case .ORDER_TIMEOUT:
            return "Order timed out"
        default:
            return "Unkonwn error"
        }
    }
}

public enum PasswordErrorType : Error {
    case SHORT_LENGTH
    case LONG_LENGTH
    case CRYPTION_ERROR
}

public struct ZaiError {
    public init(errorType: ZaiErrorType=ZaiErrorType.UNKNOWN_ERROR, message: String="") {
        self.errorType = errorType
        self.message = message
    }
    
    public let errorType: ZaiErrorType
    public let message: String
}
