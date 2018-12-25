//
//  Task.swift
//  taskapp
//
//  Created by AiTH2 on 2018/12/18.
//  Copyright © 2018 hirohisa.kimura. All rights reserved.
//

import RealmSwift

class Task: Object {
    //@objc修飾子はKVO（key-value-observing）パターンだから必要らしい
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // 内容
    @objc dynamic var contents = ""
    
    /// 日時
    @objc dynamic var date = Date()
    
    //カテゴリー
    @objc dynamic var category: Category?
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    
}
