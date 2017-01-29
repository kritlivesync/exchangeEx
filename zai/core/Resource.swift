//
//  Resource.swift
//  zai
//
//  Created by Kyota Watanabe on 1/28/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation


class Resource {
    static var invalidUserIdOrPassword: String {
        return "ユーザーIDまたはパスワードが違います。"
    }
    static var invalidPassword: String {
        return "現在のパスワードが違います。"
    }
    static var passwordSameAsCurrent: String {
        return "現在と同じパスワードは設定できません。"
    }
    static var invalidUserIdLength: String {
        return "ユーザーIDは\(minUserIdLength)〜\(maxUserIdLength)文字の範囲で設定してください。"
    }
    static var userIdAlreadyUsed: String {
        return "このユーザーIDは既に使われています。別のIDを入力してください。"
    }
    static var passwordAgainNotMatch: String {
        return "再入力パスワードが一致しません。"
    }
    static var invalidPasswordLength: String {
        return "パスワードは\(minPasswordLength)〜\(maxPasswordLength)文字の範囲で設定してください。"
    }
    static var accountCreationFailed: String {
        return "アカウント生成に失敗しました。"
    }
    static var networkConnectionError: String {
        return "ネットワークエラーが発生しました。"
    }
    static var unknownError: String {
        return "予期しないエラーが発生しました。"
    }
    var apiKeyNoPermission: String {
        return "APIキーに権限がありません。"
    }
    var apiKeyNonceNotIncremented: String {
        return "APIキーのnonce値の設定に失敗しました。しばらく時間を置くか、別のAPIキーを使用してください。"
    }
    var invalidApiKey: String {
        return "有効なAPIキーを設定してください。"
    }
    
}

class ZaifResource : Resource {
    
    override var apiKeyNoPermission: String {
        return "Zaif APIキーに権限がありません。以下の権限を持ったAPIキーを使用してください。\ninfo\ntrade"
    }
    override var apiKeyNonceNotIncremented: String {
        return "Zaif APIキーのnonce値の設定に失敗しました。しばらく時間を置くか、別のAPIキーを使用してください。"
    }
    override var invalidApiKey: String {
        return "有効なZaif APIキーを設定してください。"
    }
}
