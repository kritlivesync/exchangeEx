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
    var invalidApiKeyRestricted: String {
        return "残高表示や取引機能が制限されます。設定画面で有効なAPIキーを設定してください。"
    }
    static var noPositionsToUnwind: String {
        return "解消できるポジションがありません。"
    }
}

class LabelResource {
    static var positionStateOpen: String {
        return "オープン"
    }
    static var positionStateClosed: String {
        return "クローズ"
    }
    static var positionStateUnwinding: String {
        return "解消中"
    }
    static var positionStateOpening: String {
        return "作成中"
    }
    static var positionStateWaiting: String {
        return "待機中"
    }
    static var positionStateDeleted: String {
        return "削除済み"
    }
    static var delete: String {
        return "削除"
    }
    static var unwind: String {
        return "解消"
    }
    static var buy: String {
        return "買う"
    }
    static var sell: String {
        return "売る"
    }
    static var make: String {
        return "メイク"
    }
    static var bestBid: String {
        return "最高\n買注文"
    }
    static var bestAsk: String {
        return "最安\n売注文"
    }
    static var ignoreApiError: String {
        return "後で設定する"
    }
    static var userIdPlacecholder: String {
        return "ユーザーID"
    }
    static var passwordPlaceholder: String {
        return "パスワード"
    }
    static var passwordAgainPlaceholder: String {
        return "パスワード確認"
    }
    static var apiKeyPlaceholder: String {
        return "APIキー"
    }
    static var secretKeyPlaceholder: String {
        return "シークレットキー"
    }
    static var zaifApiKeySection: String {
        return "Zaif取引APIキー"
    }
    static var biyFlyerApiKeySection: String {
        return "bitFlyer Lightning APIキー"
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

class bitFlyerResource : Resource {
    override var apiKeyNoPermission: String {
        return "bitFlyer APIキーに権限がありません。以下の権限を持ったAPIキーを使用してください。\n資産\nトレード"
    }

    override var invalidApiKey: String {
        return "有効なbitFlyer APIキーを設定してください。"
    }
}
