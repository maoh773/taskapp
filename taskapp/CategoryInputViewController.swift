//
//  CategoryInputViewController.swift
//  taskapp
//
//  Created by AiTH2 on 2018/12/24.
//  Copyright © 2018 hirohisa.kimura. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    
    let realm = try! Realm()
    // primaryId順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    
    
    @IBAction func addCategoryItem(_ sender: UIButton) {
        let userInputText = self.textField.text!
        if userInputText.count == 0 {
            let alert: UIAlertController = UIAlertController(title: "カテゴリー名を入力してください", message: "", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        try! realm.write {
            let category = Category()
            let allCategory = realm.objects(Category.self)
            if allCategory.count != 0 {
                category.id = allCategory.max(ofProperty: "id")! + 1
            }
            category.name = userInputText
            self.realm.add(category, update: true)
        }

        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // Section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Sectioのタイトル
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return "過去に追加した項目"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
        return cell
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = self.categoryArray[indexPath.row]
            // データベースから削除する
            try! realm.write {
                self.realm.delete(category)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }


}
