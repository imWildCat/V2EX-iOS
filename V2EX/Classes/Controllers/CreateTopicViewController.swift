//
//  CreateTopicViewController.swift
//  V2EX
//
//  Created by WildCat on 12/04/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class CreateTopicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var nodeSlug: String!
    var onceCode: String = ""
    
    weak var topicListVC: TopicListViewController?

    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var contentTextBottomConstraint: NSLayoutConstraint!
    
//    lazy var cancelButton: UIBarButtonItem = { [unowned self] in
//        let canceButtonlImage = UIImage(named: "close_icon")
//        let cancelButton = UIBarButtonItem(image: canceButtonlImage, style: .Plain, target: self, action: Selector("close"))
//        return cancelButton
//    }()
//    
//    lazy var postButton: UIBarButtonItem = { [unowned self] in
//        let postButtonImage = UIImage(named: "post_button")
//        let postButton = UIBarButtonItem(image: postButtonImage, style: .Plain, target: self, action: Selector("post"))
//        return postButton
//    }()
    
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
    
    @IBAction func didCancelButtonTouch(sender: UIBarButtonItem) {
        dismissSelf()
    }

    
    @IBAction func ddidPostButtonTouch(sender: UIButton) {
        if onceCode == "" {
            showError(status: "暂时无法发布，请稍候")
            loadOnceCode()
            return
        }
        
        showProgressView()
        TopicSerivce.createTopic(onceCode: onceCode, nodeSlug: nodeSlug, title: titleText.text ?? "", content: contentText.text) { [weak self] (error, topic, problemMessage) -> Void in
            self?.hideProgressView()
          
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
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        print("will show")
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
    
    
    // MARK: Image picker
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
                        self?.showSuccess(status: "图片上传成功")
                        print("imageLink: \(imageLink)")
                        let orginalText = self?.contentText.text ?? ""
                        let newContent = orginalText + "\n\(imageLink)"
                        self?.contentText.text = newContent
                    }
                })
        }
    }

}
