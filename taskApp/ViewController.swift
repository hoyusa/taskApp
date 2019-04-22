//
//  ViewController.swift
//  taskApp
//
//  Created by 許 裕士 on 2019/04/15.
//  Copyright © 2019 許 裕士. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categorySearch: UISearchBar!
    
    //Realmのインスタンスを取得する
    let realm = try! Realm()
    //    var searchResult: [String] = []
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        categorySearch.delegate = self
        categorySearch.showsCancelButton = true
        categorySearch.placeholder = "カテゴリを入力してください"
    }
    
    func searchBar(_searchBar: UISearchBar, textDidChange searchText: String) {
        categorySearch.text = searchText
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        categorySearch.text = ""
    }
    
    //segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }
        //segueの指定を分かりやすくする為
        if segue.identifier == "addTask" {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    //入力画面から戻って来た時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    @IBAction func tapAddTaskButton(_ sender: UIBarButtonItem) {
        let task = Task()
        task.date = Date()
        let allTasks = realm.objects(Task.self)
        if allTasks.count != 0 {
            task.id = allTasks.max(ofProperty: "id")! + 1
        }
        //ここでSegueの画面呼び出しに飛ぶ
        self.performSegue(withIdentifier: "addTask", sender: task)
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM--dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //検索ボタンが押された時に呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("----------------")
        print(categorySearch.text!)
        print("----------------")
        
        //SearchBarの状態を判定
        if categorySearch.text == "" {
            //Cellに全Taskを表示する
            taskArray = realm.objects(Task.self)
            print("カテゴリ欄空だよ")
        }
        else{
            print("カテゴリ欄空じゃなかったよ")
            //カテゴリを指定する
            taskArray = realm.objects(Task.self).filter("category BEGINSWITH %@", categorySearch.text)
            print("カテゴリを\(categorySearch.text)指定したよ")
        }
        tableView.reloadData()
    }
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            print("😄😄😄\(indexPath.row)😄😄😄")
            
            //ローカル通信をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------")
                    print(requests)
                    print("---------/")
                }
                
            }
        }
        
    }
}


