//
//  ViewController.swift
//  taskapp
//
//  Created by AiTH2 on 2018/12/17.
//  Copyright © 2018 hirohisa.kimura. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications


protocol TableViewRefineDelegate {
    func updateTableView(_ categoryId: Int?)
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableViewRefineDelegate {

    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    var sectionTitle: String = "全て"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func updateTableView(_ categoryId: Int?) {
        print("bbb::\(taskArray)")
        if categoryId == nil{
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
            sectionTitle = "全て"
        } else {
            taskArray = try! Realm().objects(Task.self).filter("category.id = \(categoryId!)").sorted(byKeyPath: "date", ascending: false)
            sectionTitle = try! (Realm().objects(Category.self).filter("id = \(categoryId!)").first?.name)!
        }
        tableView.reloadData()
        print("bbb::\(taskArray)")
    }
    
    
    // Section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Sectioのタイトル
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return sectionTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString: String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "categorySelect" {
            let vc: CategorySelectModalViewController = segue.destination as! CategorySelectModalViewController
            vc.modalPresentationStyle = .overCurrentContext
            vc.tableViewRefineDelegate = self
            return
        }
        
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    

}

