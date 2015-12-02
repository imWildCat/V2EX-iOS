//
//  SettingController.swift
//  V2EX
//
//  Created by WildCat on 12/1/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import UIKit
import Eureka
import SDWebImage
import TSMessages

class SettingController: FormViewController {
    
    var clearCacheRow: LabelRow!
    var logOutRow: LabelRow!
    var logoutEnable: Bool = SessionStorage.sharedStorage.isLoggedIn {
        willSet(newValue) {
            if newValue {
                logOutRow.cell.textLabel?.enabled = true
                logOutRow.cell.textLabel?.text = "注销登录"
            } else {
                logOutRow.cell.textLabel?.enabled = false
                logOutRow.cell.textLabel?.text = "尚未登录"
            }
        }
    }
    
    private func setUpSectionsAndRows() {
        clearCacheRow = LabelRow() {
            $0.title = "清除缓存"
            }.onCellSelection {
                let imageCahce = SDImageCache.sharedImageCache()
                imageCahce.clearMemory()
                imageCahce.clearDisk()
                self.showSuccessMessage("缓存已清除")
                $0.cell.detailTextLabel?.text = "0.0 MB"
        }
        logOutRow = LabelRow() {
            $0.title = "注销登录"
            }.onCellSelection { [unowned self] cell, row in
                self.performLogOut()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSectionsAndRows()
        
//        URLRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .blueColor() }
        LabelRow.defaultCellUpdate = { cell, row in
//            cell.detailTextLabel?.textColor = .orangeColor()
            cell.tintColor = .grayColor()
        }
//        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = .orangeColor() }
//        DateRow.defaultRowInitializer = { row in row.minimumDate = NSDate() }
        
        form = Section() { section in
            section.header = HeaderFooterView<UIView>(.Class)
            section.header?.height = { 65 + 16 }
            }
            <<< PushRow<TopicFontSize>() { [unowned self] in
                $0.title = "贴子字体大小"
                $0.value = self.dynamicType.topicFontSizeSetting
                $0.options = [.Normal, .Small, .Large]
                }.onChange{ [unowned self] row in
                    if let newValue = row.value {
                        self.dynamicType.topicFontSizeSetting = newValue
                    }
            }
            <<< clearCacheRow
            <<< SwitchRow() { [unowned self] in
                $0.title = "后台提醒"
                $0.value = self.dynamicType.shouldPeformBackgroundFetch
                }.onChange { [unowned self] row in
                    if let should = row.value {
                        self.dynamicType.shouldPeformBackgroundFetch = should
                    }
            }
            +++ Section()
            <<< logOutRow
            +++ Section()
            <<< LabelRow() {
                $0.title = "关于"
                $0.cell.accessoryType = .DisclosureIndicator
                }.onCellSelection { [unowned self] _ in
                    self.showWebBrowser("http://v2ex-ios.wildcat.io/about")
            }
            <<< LabelRow() {
                $0.title = "反馈"
                $0.cell.accessoryType = .DisclosureIndicator
                }.onCellSelection { [unowned self] _ in
                    let agent = LCUserFeedbackAgent.sharedInstance()
                    agent.showConversations(self, title: nil, contact: "")
            }
    }
    
    override func viewWillAppear(animated: Bool) {
        let imageCahce = SDImageCache.sharedImageCache()
        let mb = Double(imageCahce.getSize()) / 1048576.0
        let mbString = String(format: "%.2f", mb)

        clearCacheRow.cell.detailTextLabel?.text = "\(mbString) MB"
        
        logoutEnable = SessionStorage.sharedStorage.isLoggedIn
    }
    
    private func performLogOut() {
        if !SessionStorage.sharedStorage.isLoggedIn {
//            TSMessage.showNotificationWithTitle("您尚未登录", type: .Warning)
            return
        }
        SessionService.logout()
        TSMessage.showNotificationWithTitle("已注销", type: .Message)
        logoutEnable = false
    }
}
