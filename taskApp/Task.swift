//
//  Task.swift
//  taskApp
//
//  Created by 許 裕士 on 2019/04/16.
//  Copyright © 2019 許 裕士. All rights reserved.
//


import RealmSwift

class Task: Object {
    //管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    @objc dynamic var category = ""
    
    //idをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
