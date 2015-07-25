//
//  CreateTopicViewController.swift
//  V2EX
//
//  Created by WildCat on 12/04/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class CreateTopicViewController: UIViewController {
    
    var nodeSlug: String!
    var onceCode: String = ""
    
    weak var topicListVC: TopicListViewController?

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var contentTextBottomConstraint: NSLayoutConstraint!
    
    lazy var cancelButton: UIBarButtonItem = { [unowned self] in
        let canceButtonlImage = UIImage(named: "close_icon")
        let cancelButton = UIBarButtonItem(image: canceButtonlImage, style: .Plain, target: self, action: Selector("close"))
        return cancelButton
    }()
    
    lazy var postButton: UIBarButtonItem = { [unowned self] in
        let postButtonImage = UIImage(named: "post_button")
        let postButton = UIBarButtonItem(image: postButtonImage, style: .Plain, target: self, action: Selector("post"))
        return postButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        loadOnceCode()
    }
    
    func loadOnceCode() {
        postButton.enabled = false
        SessionService.getOnceCode { [weak self](error, code) in
            self?.postButton.enabled = true
            if error != nil {
                self?.showError(status: "网络错误。", completion: nil)
                return
            }
            self?.onceCode = code
        }
    }
    
    func setUpViews() {
        navItem.leftBarButtonItem = cancelButton
        navItem.rightBarButtonItem = postButton
        
        // contentText
        contentText.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        contentText.layer.borderWidth = 0.5
        contentText.layer.cornerRadius = 5;
        contentText.clipsToBounds = true
        
        // keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil);
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func close() {
        dismissSelf()
    }
    
    func post() {
        if onceCode == "" {
            showError(status: "暂时无法发布，请稍候。")
            loadOnceCode()
            return
        }
        
        showProgressView()
        TopicSerivce.createTopic(onceCode: onceCode, nodeSlug: nodeSlug, title: titleText.text, content: contentText.text) { [weak self](error, topic, problemMessage) -> Void in
            self?.hideProgressView()
            println(topic?.id ?? 0)
            println(problemMessage ?? "")
            if let pMessage = problemMessage {
                self?.showError(status: pMessage)
                return
            } else {
                if let parentVC = self?.topicListVC, newTopic = topic {
                    parentVC.showTopic(newTopic)
                    self?.showSuccess(status: "话题创建成功") { () -> Void in
                        self?.dismissSelf()
                    }
                } else {
                    self?.showError(status: "未知错误，发贴失败。")
                }
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        println("will show")
        // FIXME: will show called twice
        UIView.animateWithDuration(0.3, animations: { [unowned self] in
            self.contentTextBottomConstraint.constant = keyboardFrame.size.height + 10
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
//        var info = notification.userInfo!
//        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { [unowned self] in
            self.contentTextBottomConstraint.constant = 10
            })
    }
    
//    func keyboardDidMove(isUp: Bool) {
//        UIView.beginAnimations(nil, context: nil)
//        UIView.setAnimationDuration(0.3)
//        
//        let rect = contentText.frame
//        let height: CGFloat
//        if isUp {
//            height = rect.size.height - keyboardOffSet
//        } else {
//            height = rect.size.height + keyboardOffSet
//        }
//        
//        contentText.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.height, height: rect.size.width)
//        UIView.commitAnimations()
//    }
    
    func dismissSelf() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
