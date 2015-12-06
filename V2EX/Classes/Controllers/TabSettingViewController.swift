//
//  TabSettingViewController.swift
//  V2EX
//
//  Created by WildCat on 12/6/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import UIKit
import CoreData

let TAB_SETTINGS_CHANGED_NOTIFICATION_KEY = "io.wildcat.wetoo.tabSettingsChangedNotificationKey"

class TabSettingViewController: UITableViewController {
    
    var tabs = [Tab]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "标签页顺序"
        editing = true
        loadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save changes
        let hasChanges = CoreDataStack.sharedStack.saveMainContext()
        if hasChanges {
            NSNotificationCenter.defaultCenter().postNotificationName(TAB_SETTINGS_CHANGED_NOTIFICATION_KEY, object: nil)
        }
    }
    
    private func loadData() {
        do {
            tabs = try Tab.fetchSortedList()
            tableView.reloadData()
        } catch _ as NSError {
            showError(status: "加载标签页设置时出错。")
        }
    }

}

// MARK: UITableViewDataSource
extension TabSettingViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabs.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = tabs[indexPath.row].name
        return cell
    }
}

// MARK: UITableViewDelegate
extension TabSettingViewController {
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let sourceTab = tabs[sourceIndexPath.row]
        let destinationTab = tabs[destinationIndexPath.row]
        (sourceTab.priority, destinationTab.priority) = (destinationTab.priority, sourceTab.priority)
    }
}
