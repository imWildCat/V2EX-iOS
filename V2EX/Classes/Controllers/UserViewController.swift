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
    
    var username: String?
    var currentUser: User? {
        didSet {
            setUpRowTypes(currentUser)
            tableView.reloadData()
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
            if let name = username {
                UserService.getUserInfo(name) { [weak self] (error, user, topicsRelated, repliesRelated) in
                    self?.currentUser = user
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
                self?.currentUser = user
            }
        }
    }
    
    private func switchToUnloginState() {
        
        if mode != .CurrentUser {
            return
        }
        
        unloginMaskButton.hidden = false
        // clear views
        currentUser = nil
    }
    
    private func switchToLoginState() {
        
        if mode != .CurrentUser {
            return
        }
        
        unloginMaskButton.hidden = true
        currentUser = SessionStorage.sharedStorage.currentUser
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
        case .Info:
            let infoCell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath) as! UserInfoTableViewCell
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
            let user = currentUser ?? User(name: "")
            introCell.introLabel.text = user.introduction ?? ""
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
    
    private func setUpInfoView(infoView: UserInfoView) {
        let user = currentUser ?? User(name: "未知用户")
        
                infoView.usernameLabel.text = user.name
                infoView.avatarImageView.layer.cornerRadius = 25.0
                infoView.avatarImageView.sd_setImageWithURL(("https:" + user.avatarURI).toURL(), placeholderImage: UIImage(named: "avatar_placeholder"))
                    { [weak infoView] (image, error, _, _)  in
                    infoView?.avatarImageView.layer.cornerRadius = 5.0
                }
        
//                avatarImageView.sd_setImageWithURL(<#url: NSURL!#>, placeholderImage: <#UIImage!#>, completed: <#SDWebImageCompletionBlock!##(UIImage!, NSError!, SDImageCacheType, NSURL!) -> Void#>)
        
                infoView.companyLabel.text = user.company
                infoView.numberLabel.text = "No. " + (user.id?.description ?? "")
                infoView.regDateLabel.text = user.createdAt ?? ""
                infoView.livenessLabel.text = user.liveness?.description ?? ""
    }
    
    private func removeCellSeparatorAndSelectionStyle(cell: UITableViewCell) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
        cell.selectionStyle = .None
    }
    
    private func setUpRowTypes(user: User?) {
        func setUpExtraInfo(user: User) {
            typeOfRows.append(.Introduction)
            // TODO: Implement for website, GitHub, Twitter
        }
        
        typeOfRows = [UserTableViewRowType]()
        typeOfRows.append(.Info)
        
        let user = currentUser ?? User(name: "未知用户")
        if mode == .CurrentUser {
            typeOfRows.append(.Notification)
            typeOfRows.append(.Favorite)
            typeOfRows.append(.Topic)
            typeOfRows.append(.Reply)
        } else {
            typeOfRows.append(.Topic)
            typeOfRows.append(.Reply)
        }
        setUpExtraInfo(user)
    }
    
    private func setUpNavButtons() {
        if mode == .CurrentUser {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "side_menu_icon"), style: .Plain , target: self, action: "showSideMenu")
        }
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 44.0
//    }
    
    
}
