//
//  InputViewController.swift
//  taskapp
//
//  Created by AiTH2 on 2018/12/17.
//  Copyright © 2018 hirohisa.kimura. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    let realm = try! Realm()
    var task: Task!
    
    // primaryId順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    var selectedRowNum = 0
    
    @IBAction func saveTask(_ sender: UIButton) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            
            if categoryArray.count == 0 {
                self.task.category = nil
            } else {
                self.task.category = categoryArray[selectedRowNum]
            }
            
            self.realm.add(self.task, update: true)
        }
        
        setNotification(task: task)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        if task.category != nil {
            let targetIndex = categoryArray.index(of: task.category!)!
            selectedRowNum = targetIndex
            categoryPicker.selectRow(targetIndex, inComponent: 0, animated: false)
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        categoryPicker.reloadAllComponents()
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }

    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row].name
    }

    // UIPickerViewが動いたら呼ばれる
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRowNum = row
    }
    
}
