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

class ReplyTopicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var parentVC: ReplyTopicViewControllerDelegate?
    var topicID: Int!
    var onceCode = ""
    var initialContent: String?

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contentTextViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Assign topic
        if let topicIDToReply = parentVC?.getTopicID() where topicIDToReply != 0 {
            topicID = topicIDToReply
        } else {
            self.dismissSelf()
            Utils.delay(0.15) {
                self.showErrorMessage("未知错误，无法回复")
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
        
        // Upload image button
//        let canceButtonlImage = UIImage(named: "close_icon")
//        let cancelButton = UIBarButtonItem(image: canceButtonlImage, style: .Plain, target: self, action: Selector("close"))
//        navigationItem.addRi
        
        // Load cached reply
        if let cachedReply = MemoryCache.getReply(topicID: topicID) {
            contentTextView.text = cachedReply
        }
        
        // Inital content, such as @user
        if let c = initialContent {
            let originalContent = contentTextView.text
            if originalContent.isEmpty {
                contentTextView.text = c
            } else {
                contentTextView.text = originalContent + "\n" + c
            }
        }
        
        loadOnceCode()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AVAnalytics.beginLogPageView("ReplyTopicViewController")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AVAnalytics.endLogPageView("ReplyTopicViewController")
    }
    
    func loadOnceCode() {
        SessionService.getOnceCode { [weak self] (result) -> Void in
            switch result {
            case .Failure(_, let error):
                self?.showError(error)
            case .Success(let code):
                self?.onceCode = code
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
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
        if !contentTextView.text.isEmpty {
            let alert = UIAlertController(title: "您有尚未发布的回复", message: "是否需要保存？", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { [unowned self] (action) -> Void in
                    self.dismissSelf()
                    MemoryCache.removeReply(topicID: self.topicID)
                }))
            alert.addAction(UIAlertAction(title: "保存", style: .Default, handler: { [unowned self] (action) -> Void in
                    MemoryCache.setReply(topicID: self.topicID, content: self.contentTextView.text)
                    self.dismissSelf()
                }))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
         dismissSelf()
    }
    
    @IBAction func didImageButtonTouch(sender: UIButton) {
        let actionSheet = UIAlertController(title: "上传图片", message: nil, preferredStyle: .ActionSheet)
        
        let takingPhotoAction = UIAlertAction(title: "拍照", style: .Default) { [unowned self](action) in
            self.showImagePicker(true)
        }
        
        let choosingPhotoAction = UIAlertAction(title: "从相册中选择", style: .Default) { [unowned self] (action) in
            self.showImagePicker(false)
        }
        
        let cancelButton = UIAlertAction(title: "取消", style: .Cancel) { (action) -> Void in
            //
        }
        
        actionSheet.addAction(takingPhotoAction)
        actionSheet.addAction(choosingPhotoAction)
        actionSheet.addAction(cancelButton)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    private func showImagePicker(isTakingPhoto: Bool) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if isTakingPhoto {
            picker.sourceType = .Camera
        } else {
            picker.sourceType = .PhotoLibrary
        }
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            showProgress(0.0, status: "图片上传中")
            
            ThirdPartyNetworking.uploadImage2SinaCustomService(image: pickedImage, progressClosure: { [weak self] (progress) in
                    self?.updateProgress(progress)
                }, responseClosure: { [weak self] (error, problemMessage, imageURL) in
                    if error != nil {
                        self?.showError()
                    } else if let pMessage = problemMessage {
                        self?.showError(status: pMessage)
                    } else if let imageLink = imageURL {
                        self?.showSuccessMessage("图片上传成功")
                        let orginalText = self?.contentTextView.text ?? ""
                        let newContent = orginalText + "\n\(imageLink)"
                        self?.contentTextView.text = newContent
                    }
            })
        }
    }
    
    @IBAction func didReplyButtonTouch(sender: UIButton) {
        
        contentTextView.resignFirstResponder()
        
        if onceCode.isEmpty {
            showErrorMessage("暂时无法发布，请稍候")
            loadOnceCode()
            return
        }
        
        if contentTextView.text.isEmpty {
            showErrorMessage("回复内容不能为空")
            return
        }
        
        showProgressView()
        TopicSerivce.replyTopic(onceCode: onceCode, topicID: topicID, content: contentTextView.text) { [weak self] (result) in
            self?.hideProgressView()
            if result.isFailure {
                self?.showError(result.error)
            } else {
                self?.parentVC?.didReplySucceed()
                self?.dismissSelf()
                Utils.delay(0.15) {
                    self?.showSuccessMessage("回复成功")
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
