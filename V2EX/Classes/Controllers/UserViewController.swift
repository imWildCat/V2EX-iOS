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
    
    var username: String?
    
    
    @IBOutlet weak var unloginMaskButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var regDateLabel: UILabel!
    @IBOutlet weak var livenessLabel: UILabel!
    
    override func viewDidLoad() {
        
       
    }
    
    override func viewWillAppear(animated: Bool) {
        let storage = SessionStorage.sharedStorage
        
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
    }
    
    private func fetchDetailInfo() {
        let storage = SessionStorage.sharedStorage
        if storage.currentUser?.id == nil && storage.currentUser?.name != nil {
            let name = storage.currentUser?.name ?? "..."
            UserService.getUserInfo(name) { [weak self] (error, user, topicsRelated, repliesRelated) in
                self?.setUpInfoViews(user)
                return
            }
        }
    }
    
    private func switchToUnloginState() {
        unloginMaskButton.hidden = false
        // clear views
        setUpInfoViews(nil)
    }
    
    private func switchToLoginState() {
        unloginMaskButton.hidden = true
        setUpInfoViews(SessionStorage.sharedStorage.currentUser)
        fetchDetailInfo()
    }
    
    
    private func setUpInfoViews(aUser: User?) {
        let user = aUser ?? User(name: "未知用户")
        
        usernameLabel.text = user.name
//        avatarImageView.layer.cornerRadius = 25.0
        avatarImageView.sd_setImageWithURL(("https:" + user.avatarURI).toURL(), placeholderImage: UIImage(named: "avatar_placeholder"))
//            { [weak self] (image, error, _, _)  in
//            self?.avatarImageView.layer.cornerRadius = 5.0
//        }
        
//        avatarImageView.sd_setImageWithURL(<#url: NSURL!#>, placeholderImage: <#UIImage!#>, completed: <#SDWebImageCompletionBlock!##(UIImage!, NSError!, SDImageCacheType, NSURL!) -> Void#>)

        companyLabel.text = user.company
        numberLabel.text = "No. " + (user.id?.description ?? "")
        regDateLabel.text = user.createdAt ?? ""
        livenessLabel.text = user.liveness?.description ?? ""
    }
 
    
    @IBAction func unloginMaskButtonDidClick(sender: UIButton) {
        showUserLoginVC()
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        switch index {
        case 0:
            return tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as! UITableViewCell
        case 1:
            return tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath) as! UITableViewCell
        case 2:
            return tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath) as! UITableViewCell
        default:
            return tableView.dequeueReusableCellWithIdentifier("replyCell", forIndexPath: indexPath) as! UITableViewCell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    
}
