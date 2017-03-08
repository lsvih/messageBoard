//
//  MasterViewController.swift
//  messageBoard
//
//  Created by lyz on 2017/3/8.
//  Copyright © 2017年 lyz. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    let isFirstLaunch = UserDefaults.standard.string(forKey: "FirstLaunch") == nil
    var objects:Array<Any> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(isFirstLaunch){
            UserDefaults.standard.set("false", forKey: "FirstLaunch")
            syncStore()
        }else{
            objects = UserDefaults.standard.value(forKey: "history") as! Array<Any>
        }
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        let alertController = UIAlertController(title: "添加备忘", message: "请输入备忘内容", preferredStyle: UIAlertControllerStyle.alert)
        let insertAction = UIAlertAction(title: "确认", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            print(alertController.textFields![0].text!)
            self.objects.insert(alertController.textFields![0].text!, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.syncStore()
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addTextField { (textField:UITextField) in
            textField.placeholder = "请输入内容"
        }
        alertController.addAction(insertAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    func syncStore(){
        UserDefaults.standard.set(objects, forKey: "history")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! String
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! String
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            syncStore()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

