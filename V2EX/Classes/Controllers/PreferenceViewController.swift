//
//  PreferenceViewController.swift
//  V2EX
//
//  Created by WildCat on 8/9/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
import RETableViewManager
import SDWebImage
import TSMessages

class PreferenceViewController: UITableViewController, RETableViewManagerDelegate {
    
    var manager: RETableViewManager!
    var section1, section2, section3: RETableViewSection!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(red:0.91, green:0.94, blue:0.95, alpha:1)
        tableView.tableFooterView = UIView()
        
        setUpSections()
        manager = RETableViewManager(tableView: tableView, delegate: self)
        configureRETableViewManager()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AVAnalytics.beginLogPageView("PreferenceViewController")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AVAnalytics.endLogPageView("PreferenceViewController")
    }
    
    class func getTopicContentFontSize() -> String {
        return NSUserDefaults.standardUserDefaults().stringForKey("topic_content_font_size") ?? "normal"
    }
    
    class func getTopicContentFontSizeName() -> String {
        let size = getTopicContentFontSize()
        switch size {
        case "large":
            return "大"
        case "small":
            return "小"
        default:
            return "正常"
        }
    }
    
    class func setTopicContentFontSize(size: String) {
        NSUserDefaults.standardUserDefaults().setObject(size, forKey: "topic_content_font_size")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setTopicContentFontSize(byName name: String) {
        var size: String!
        switch name {
        case "大":
            size = "large"
        case "小":
            size = "small"
        default:
            size = "normal"
        }
        self.setTopicContentFontSize(size)
    }
    
    // MARK: RETableViewManager
    func setUpSections() {
        section1 = RETableViewSection()
        
//        _ = RERadioItem(title: "图片显示", value: "全部自动加载") { [unowned self, section1](item) -> Void in
//            item.deselectRowAnimated(true)
//            
//            //            let options = ["全部自动加载", "Wi-Fi 下自动加载", "不加载"] as NSArray
//            
//            let optionsController = RETableViewOptionsController(item: item, options: ["全部自动加载", "Wi-Fi 下自动加载", "不加载"], multipleChoice: false) { [weak self, item](selectedItem) -> Void in
//                self?.navigationController?.popViewControllerAnimated(true)
//                item?.reloadRowWithAnimation(UITableViewRowAnimation.None)
//            }
//            
//            optionsController.delegate = self
//            optionsController.style = section1.style
//            optionsController.tableView.backgroundColor = self.tableView.backgroundColor;
//            optionsController.tableView.tintColor = self.tableView.tintColor
//            self.navigationController?.pushViewController(optionsController, animated: true)
//        }
        
        let topicContentFontSizeItem = RERadioItem(title: "内容字体大小", value: self.dynamicType.getTopicContentFontSizeName()) { [unowned self, section1](item) -> Void in
           
//            
            let options = ["小", "正常", "大"]
            
            let optionsController = RETableViewOptionsController(item: item, options: options, multipleChoice: false) { [weak self, item](selectedItem) -> Void in
                self?.navigationController?.popViewControllerAnimated(true)
                let fontSizeName = options[selectedItem.indexPath().row]
                self?.dynamicType.setTopicContentFontSize(byName: fontSizeName)
                item?.reloadRowWithAnimation(UITableViewRowAnimation.None)
            }
            
            optionsController.delegate = self
            optionsController.style = section1.style
            optionsController.tableView.backgroundColor = self.tableView.backgroundColor;
            optionsController.tableView.tintColor = self.tableView.tintColor
            self.navigationController?.pushViewController(optionsController, animated: true)
        }
        
        let clearCacheItem = RETableViewItem(title: "清除缓存", accessoryType: .None) { [unowned self] (selectedItem) -> Void in
            selectedItem.reloadRowWithAnimation(UITableViewRowAnimation.None)
            let imageCahce = SDImageCache.sharedImageCache()
            imageCahce.clearMemory()
            imageCahce.clearDisk()
            self.showSuccess(status: "已清除")
        }
        
        
        let shouldDoBackgroundFetch = NSUserDefaults.standardUserDefaults().boolForKey("should_do_background_fetch")
        
        let backgroundNotificationItem = REBoolItem(title: "后台提醒", value: shouldDoBackgroundFetch) { (item) -> Void in
            let sholdFetch = item.value
            NSUserDefaults.standardUserDefaults().setBool(sholdFetch, forKey: "should_do_background_fetch")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        _ = RETableViewItem(title: "购买完整版", accessoryType: .DisclosureIndicator) { [unowned self] (selectedItem) -> Void in
            selectedItem.reloadRowWithAnimation(UITableViewRowAnimation.None)
            self.showPurchaseVC()
        }
        
        section1.addItemsFromArray([topicContentFontSizeItem, clearCacheItem, backgroundNotificationItem])
        
        section2 = RETableViewSection()
        let logOutItem = RETableViewItem(title: "注销登录", accessoryType: .None) { [unowned self] (selectedItem) -> Void in
            selectedItem.reloadRowWithAnimation(UITableViewRowAnimation.None)
            self.performLogOut()
        }
        section2.addItemsFromArray([logOutItem])
        
        section3 = RETableViewSection()
        
        let aboutItem = RETableViewItem(title: "关于", accessoryType: .DisclosureIndicator) { [unowned self] (selectedItem) -> Void in
            self.showWebBrowser("http://v2ex-ios.wildcat.io/about")
            selectedItem.reloadRowWithAnimation(UITableViewRowAnimation.None)
        }
        
        let feedbackItem = RETableViewItem(title: "反馈", accessoryType: .DisclosureIndicator) { [unowned self] (selectedItem) -> Void in
            let agent = LCUserFeedbackAgent.sharedInstance()
            agent.showConversations(self, title: nil, contact: "请输入你的 Email")
            selectedItem.reloadRowWithAnimation(UITableViewRowAnimation.None)
        }

        section3.addItemsFromArray([aboutItem, feedbackItem])
    }
    
    func configureRETableViewManager() {

        
        manager.addSection(section1)
        manager.addSection(section2)
        manager.addSection(section3)
        
//        if !SessionStorage.sharedStorage.isLoggedIn && manager.sections.count > 2 {
//            manager.removeSectionAtIndex(1)
//        } else if SessionStorage.sharedStorage.isLoggedIn && manager.sections.count == 2 {
//            manager.addSection(section2)
//        }
    }

    
    
    private func performLogOut() {
        
        if !SessionStorage.sharedStorage.isLoggedIn {
//            showError(status: "您尚未登录")
            TSMessage.showNotificationWithTitle("您尚未登录", type: .Warning)
            return
        }
        
        SessionService.logout() // TODO: move it to SessionService
        configureRETableViewManager()
//        showSuccess(status: "已注销")
        TSMessage.showNotificationWithTitle("已注销", type: .Message)
    }
//    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }

//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
