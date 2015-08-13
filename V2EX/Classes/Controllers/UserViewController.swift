//
//  UserViewController.swift
//  V2EX
//
//  Created by WildCat on 13/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit
import SDWebImage


class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum UserViewControllerMode {
        case CurrentUser
        case OtherUser
    }
    
    enum UserTableViewRowType {
        case DailyRedeem
        case Info
        case Notification
        case Favorite
        case Topic
        case Reply
        case Introduction
        case WebSite
        case Twitter
        case GitHub
    }
    
    var mode: UserViewControllerMode = .CurrentUser
    
    var typeOfRows = [UserTableViewRowType]()
    
    var shouldDisplayDailyRedeem = false
    
    var username: String?
    var user: User? {
        didSet {
            setUpRowTypes(user)
            if mode == .CurrentUser {
                checkDailyTask()
            }
        }
    }
    
    @IBOutlet weak var unloginMaskButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
//        tableView.separatorStyle = .None
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if mode == .CurrentUser {
            let storage = SessionStorage.sharedStorage
            username = storage.currentUser?.name
            if (NSDate.currentTimestamp() - storage.lastLogin) < UInt(24.hours.toSeconds) {
                switchToLoginState()
            } else {
                SessionService.checkLogin { [weak self] (error, isLoggedIn) in
                    if error != nil {
                        self?.showError(status: "网络错误，无法检查您的登录状态") {
                            self?.switchToUnloginState()
                            return
                        }
                    } else if isLoggedIn {
                        self?.switchToLoginState()
                    } else {
                        self?.switchToUnloginState()
                    }
                }
            }
        } else {
            navigationItem.title = "用户信息"
            
            if let name = username {
                UserService.getUserInfo(name) { [weak self] (error, user, topicsRelated, repliesRelated) in
                    self?.user = user
                }
            } else {
                showError(status: "用户未定义，无法加载信息。")
            }
        }
        
        setUpNavButtons()
    }
    
    private func fetchCurrentUserDetailInfo() {
        let storage = SessionStorage.sharedStorage
        if storage.currentUser?.id == nil && storage.currentUser?.name != nil {
            let name = storage.currentUser?.name ?? "..."
            UserService.getUserInfo(name) { [weak self] (error, user, topicsRelated, repliesRelated) in
                self?.user = user
            }
        }
    }
    
    private func switchToUnloginState() {
        
        if mode != .CurrentUser {
            return
        }
        
        unloginMaskButton.hidden = false
        // clear views
        user = nil
    }
    
    private func switchToLoginState() {
        
        if mode != .CurrentUser {
            return
        }
        
        unloginMaskButton.hidden = true
        user = SessionStorage.sharedStorage.currentUser
        fetchCurrentUserDetailInfo()
    }
    
    @IBAction func unloginMaskButtonDidClick(sender: UIButton) {
        showUserLoginVC()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if username == nil {
            showError(status: "未知用户")
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier, uname = username {
            switch identifier {
            case "showUserTopicVC":
                let userTopicVC = segue.destinationViewController as! UserTopicListViewController
                userTopicVC.username = uname
            case "showUserReplyVC":
                let userReplyVC = segue.destinationViewController as! UserReplyListController
                userReplyVC.username = uname
            default:
                println("Do nothing prepareForSegue: \(identifier)")
            }
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let type = typeOfRows[index]
        switch type {
        case .DailyRedeem:
            let dailyRedeemCell = tableView.dequeueReusableCellWithIdentifier("dailyRedeemCell", forIndexPath: indexPath) as! UITableViewCell
            return dailyRedeemCell
        case .Info:
            let infoCell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath) as! UserInfoTableViewCell
            if mode == .OtherUser {
                infoCell.infoView.mode = .OtherUser
            }
            setUpInfoView(infoCell.infoView)
            removeCellSeparatorAndSelectionStyle(infoCell)
            return infoCell
        case .Notification:
            let cell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        case .Favorite:
            let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        case .Topic:
            let cell = tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        case .Reply:
            let cell = tableView.dequeueReusableCellWithIdentifier("replyCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        case .Introduction:
            let introCell = tableView.dequeueReusableCellWithIdentifier("introCell", forIndexPath: indexPath) as! UserIntroTableViewCell
            let aUser = user ?? User(name: "")
            introCell.introLabel.text = aUser.introduction ?? ""
            removeCellSeparatorAndSelectionStyle(introCell)
            return introCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeOfRows.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if typeOfRows[indexPath.row] == .DailyRedeem {
            SessionService.getDailyRedeem({ [weak self] (error) -> Void in
                if error == nil {
                    self?.showSuccess(status: "已领取今日登陆奖励")
                    self?.setUpRowTypes(self?.user, shouldDisplayDailyRedeem: false)
                } else {
                    self?.showError(error)
                }
            })
        }
    }
    
    private func setUpInfoView(infoView: UserInfoView) {
        let aUser = user ?? User(name: "未知用户")
        
                infoView.usernameLabel.text = aUser.name
                infoView.avatarImageView.layer.cornerRadius = 25.0
                infoView.avatarImageView.sd_setImageWithURL(("https:" + aUser.avatarURI).toURL(), placeholderImage: UIImage(named: "avatar_placeholder"))
                    { [weak infoView] (image, error, _, _)  in
                    infoView?.avatarImageView.layer.cornerRadius = 5.0
                }
        
//                avatarImageView.sd_setImageWithURL(<#url: NSURL!#>, placeholderImage: <#UIImage!#>, completed: <#SDWebImageCompletionBlock!##(UIImage!, NSError!, SDImageCacheType, NSURL!) -> Void#>)
        
                infoView.companyLabel.text = aUser.company
                infoView.numberLabel.text = "No. " + (aUser.id?.description ?? "")
                infoView.regDateLabel.text = aUser.createdAt ?? ""
                infoView.livenessLabel.text = aUser.liveness?.description ?? ""
    }
    
    private func removeCellSeparatorAndSelectionStyle(cell: UITableViewCell) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
        cell.selectionStyle = .None
    }
    
    private func setUpRowTypes(user: User?, shouldDisplayDailyRedeem: Bool = false) {
        func setUpExtraInfo(user: User) {
            typeOfRows.append(.Introduction)
            // TODO: Implement for website, GitHub, Twitter
        }
        
        typeOfRows = [UserTableViewRowType]()
        typeOfRows.append(.Info)
        
        let user = user ?? User(name: "未知用户")
        if mode == .CurrentUser {
            if shouldDisplayDailyRedeem {
                typeOfRows.append(.DailyRedeem)
            }
            typeOfRows.append(.Notification)
            typeOfRows.append(.Favorite)
            typeOfRows.append(.Topic)
            typeOfRows.append(.Reply)
        } else {
            typeOfRows.append(.Topic)
            typeOfRows.append(.Reply)
        }
        setUpExtraInfo(user)
        tableView.reloadData()
    }
    
    private func setUpNavButtons() {
        if mode == .CurrentUser {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "side_menu_icon"), style: .Plain , target: self, action: "showSideMenu")
        }
    }
    
    private func checkDailyTask() {
        SessionService.checkDailyRedeem { [weak self] (error, onceCode) -> Void in
            if let _ = onceCode {
               self?.setUpRowTypes(self?.user, shouldDisplayDailyRedeem: true)
            }
        }
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 44.0
//    }
    
    
}
