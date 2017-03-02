//
//  ApiError.swift
//  zai
//
//  Created by Kyota Watanabe on 1/1/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation


public enum ApiErrorType : Error {
    case NO_PERMISSION
    case NONCE_NOT_INCREMENTED
    case INVALID_API_KEY
    case INVALID_ORDER
    case INVALID_ORDER_AMOUNT
    case INSUFFICIENT_FUNDS
    case ORDER_NOT_FOUND
    case ORDER_NOT_ACTIVE
    case CONNECTION_ERROR
    case EXCHANGE_DOWN
    case UNKNOWN_ERROR
}


public struct ApiError {
    public init(errorType: ApiErrorType = .UNKNOWN_ERROR, message: String="") {
        self.errorType = errorType
        self.message = message
    }
    
    public let errorType: ApiErrorType
    public let message: String
}
