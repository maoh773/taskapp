//
//  Category.swift
//  taskapp
//
//  Created by AiTH2 on 2018/12/24.
//  Copyright © 2018 hirohisa.kimura. All rights reserved.
//

import RealmSwift

class Category: Object {
    //@objc修飾子はKVO（key-value-observing）パターンだから必要らしい
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var name = ""
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }

    
}
