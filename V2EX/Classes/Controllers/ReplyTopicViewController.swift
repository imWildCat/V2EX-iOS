//
//  ReplyTopicViewController.swift
//  V2EX
//
//  Created by WildCat on 7/27/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

protocol ReplyTopicViewControllerDelegate: class {
    func getTopicID() -> Int
    func didReplySucceed()
    func didReplyCancelWithDraft()
}

class ReplyTopicViewController: UIViewController {
    
    weak var parentVC: ReplyTopicViewControllerDelegate?
    var topicID: Int!
    var onceCode = ""

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contentTextViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Assign topic
        if let topicIDToReply = parentVC?.getTopicID() where topicIDToReply != 0 {
            topicID = topicIDToReply
        } else {
            showError(status: "未知错误，无法回复") { [unowned self] in
                self.dismissSelf()
            }
        }
        
        // contentTextView
        contentTextView.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        contentTextView.layer.borderWidth = 0.5
        contentTextView.layer.cornerRadius = 5;
        contentTextView.clipsToBounds = true
        
        // keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil);
        
        loadOnceCode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadOnceCode() {
        SessionService.getOnceCode { [weak self] (error, code) -> Void in
            self?.onceCode = code
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        println("will show")
        // FIXME: will show called twice
        UIView.animateWithDuration(0.3, animations: { [unowned self] in
            self.contentTextViewBottomConstraint.constant = keyboardFrame.size.height + 10
            })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { [unowned self] in
            self.contentTextViewBottomConstraint.constant = 10
            })
    }
    
    @IBAction func didCloseButtonTouch(sender: UIBarButtonItem) {
        dismissSelf()
    }
    
    @IBAction func didReplyButtonTouch(sender: UIBarButtonItem) {
        
        contentTextView.resignFirstResponder()
        
        if onceCode.isEmpty {
            showError(status: "暂时无法发布，请稍候")
            loadOnceCode()
            return
        }
        
        showProgressView()
        TopicSerivce.replyTopic(onceCode: onceCode, topicID: topicID, content: contentTextView.text) { [weak self] (error, problemMessage) -> Void in
            self?.hideProgressView()
            if error != nil {
                self?.showError(.Networking)
            } else if problemMessage != nil {
                self?.showError(status: problemMessage!)
            } else {
                self?.showSuccess(status: "回复成功") {
                    self?.parentVC?.didReplySucceed()
                    self?.dismissSelf()
                }
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func dismissSelf() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
