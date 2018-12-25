//
//  categorySelectModalViewController.swift
//  taskapp
//
//  Created by AiTH2 on 2018/12/25.
//  Copyright © 2018 hirohisa.kimura. All rights reserved.
//

import UIKit
import RealmSwift

class CategorySelectModalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    let realm = try! Realm()
    // primaryId順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: false)
    var selectedCategoryId: Int? = nil
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var tableViewRefineDelegate: TableViewRefineDelegate!
    
    @IBAction func done(_ sender: UIBarButtonItem) {

        dismiss(
            animated: true,
            completion: {
                if self.categoryArray.count == 0 {return}
                self.tableViewRefineDelegate.updateTableView(self.selectedCategoryId)
            }
        )
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func allCategory(_ sender: UIBarButtonItem) {
        
        dismiss(
            animated: true,
            completion: {
                self.tableViewRefineDelegate.updateTableView(nil)
            }
        )
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        
        selectedCategoryId = categoryArray.count - 1
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0.5,
            options: [.curveEaseIn],
            animations: {
                self.view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.2)
            },
            completion: nil
        )
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row].name
    }
    
    // UIPickerViewが動いたら呼ばれる
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categoryArray.count == 0 {return}
        selectedCategoryId = categoryArray[row].id
    }


}
