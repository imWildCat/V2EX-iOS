//
//  TopicViewController.swift
//  V2EX
//
//  Created by WildCat on 15/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
//import WebKit

class TopicViewController: UIViewController, UIWebViewDelegate, ReplyTopicViewControllerDelegate {
    
    enum Mode {
        case ReadTopic
        case NewTopic
    }
    @IBOutlet weak var previousPageButton: UIBarButtonItem!
    @IBOutlet weak var pageNumberButton: UIBarButtonItem!
    @IBOutlet weak var nextPageButton: UIBarButtonItem!
    @IBOutlet weak var appreciationButton: UIBarButtonItem!
    
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    @IBOutlet weak var popoverMenu: UIView!
    @IBOutlet weak var maskButton: UIButton!

    @IBOutlet weak var webView: UIWebView!
//    var webView: WKWebView
    var mode = Mode.ReadTopic
    var topicID = 0
    var topic: Topic?

    required init(coder aDecoder: NSCoder) {
//        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        webView.backgroundColor = UIColor(red: 253/255, green: 248/255, blue: 234/255, alpha: 1)
        webView.opaque = false
        webView.delegate = self
        
//        view.addSubview(webView)
//        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        let widthConstraint = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
//        view.addConstraint(widthConstraint)
//        let heightConstraint = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
//        view.addConstraint(heightConstraint)
        
        requestTopic()
    }
    
    private func showMask() {
        maskButton.hidden = false
        self.maskButton.alpha = 0
        AnimationHelper.spring(0.5, animations: {
            self.maskButton.alpha = 1
        })
    }
    
    private func showPopoverMenu() {
        popoverMenu.hidden = false
        showMask()
        
        let scale = CGAffineTransformMakeScale(0.3, 0.3)
        let translate = CGAffineTransformMakeTranslation(50, -50)
        self.popoverMenu.transform = CGAffineTransformConcat(scale, translate)
        self.popoverMenu.alpha = 0
        
        AnimationHelper.spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.popoverMenu.transform = CGAffineTransformConcat(scale, translate)
            self.popoverMenu.alpha = 1
        }
    }
    
    private func hidePopoverMenuAndMask() {
        AnimationHelper.spring(0.5, animations: {
            self.popoverMenu.alpha = 0
            self.maskButton.alpha = 0
            self.popoverMenu.hidden = true
            self.maskButton.hidden = true
        })
    }
    
    @IBAction func rightNavButtonDidTouched(sender: AnyObject) {
        if popoverMenu.hidden == false {
            return
        }
        showPopoverMenu()
    }
    @IBAction func maskButtonDidTouched(sender: AnyObject) {
        hidePopoverMenuAndMask()
    }
    @IBAction func sharingButtonDidTouched(sender: AnyObject) {
        hidePopoverMenuAndMask()
        
        var sharingItems = [AnyObject]()
        
        if let url = NSURL(string: "https://www.v2ex.com/t/\(topicID)") {
            let activityVC = UIActivityViewController(activityItems: sharingItems, applicationActivities: [])
            presentViewController(activityVC, animated: true, completion: nil)
        }
    }

    @IBAction func safariButtonDidTouched(sender: AnyObject) {
        hidePopoverMenuAndMask()
        
        if let url = NSURL(string: "https://www.v2ex.com/t/\(topicID)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    @IBAction func copyButtonDidTouched(sender: AnyObject) {
        hidePopoverMenuAndMask()
        
        let urlString = "https://www.v2ex.com/t/\(topicID)"
        UIPasteboard.generalPasteboard().string = urlString
        
        showSuccess(status: "链接已复制")
    }
    @IBAction func ignoringButtonDidTouched(sender: AnyObject) {
        hidePopoverMenuAndMask()
        
        showProgressView()
        SessionService.ignoreTopic(topicID) { [weak self] (error) in
            if error != nil {
                self?.showError(error)
            } else {
                self?.showSuccess(status: "忽略成功")
            }
        }
    }
    @IBAction func reportingButtonDidTouched(sender: AnyObject) {
        hidePopoverMenuAndMask()
        
        if isLoggedIn {
            println(topic)
            if topic?.isReported == true {
                showError(status: "您已经报告过这个主题了")
                return
            }

            if let rLink = topic?.reportLink {
                showProgressView()
                SessionService.reportTopic(rLink) { [weak self] (error) -> Void in
                    if error != nil {
                        self?.showError(error)
                    } else {
                        self?.showSuccess(status: "你已对本主题进行了报告")
                        self?.topic?.isReported = true
                    }
                }
            }
        }

    }
    
    
    func requestTopic(finished: (() -> Void)? = nil) {
        let path = NSBundle.mainBundle().bundlePath
        let baseURL = NSURL.fileURLWithPath(path)
        
        if let newTopic = topic where mode == .NewTopic {
            webView.loadHTMLString(TopicViewModel.renderHTML(newTopic, replies: []), baseURL: baseURL)
            topicID = newTopic.id
            topic = nil
            return
        }
        
        showProgressView()
        TopicSerivce.singleTopic(topicID, response: { [weak self, finished] (error, fetchedTopic, replies)  in
            self?.webView.loadHTMLString(TopicViewModel.renderHTML(fetchedTopic, replies: replies), baseURL: baseURL)
            self?.hideProgressView()
            self?.topicID = fetchedTopic.id
            self?.topic = fetchedTopic
            finished?()
            
            self?.configureFavButton()
            self?.configureAppreciationButton()
        })
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let scheme = request.URL?.scheme {
//            println(request.URLString)

            if scheme == "file" {
                return true
            }
            
            if scheme == "webview" {
                actionHanlder(request.URLString)
                return false
            }
        }
        
        return false
    }
    
    func showReplyTopicVC() {
        if let replyTopicVC = storyboard?.instantiateViewControllerWithIdentifier("replyTopicVC") as? ReplyTopicViewController {
            replyTopicVC.parentVC = self
            presentViewController(replyTopicVC, animated: true, completion: nil)
        } else {
            showError(status: "节点未定义，无法创建话题")
        }
    }
    
    @IBAction func didReplyButtonTouch(sender: UIBarButtonItem) {
        showReplyTopicVC()
    }
    
    func actionHanlder(URL: String) {
        let (action, params) = URL.parseWebViewAction()
        switch action {
        case .OpenBrowser:
            openWebBrowser(params["url"])
        case .User:
            userDidClick(params["username"])
        default:
            break
        }
    }
    
    func openWebBrowser(URL: String?) {
        if let wrappedURL = URL, browserVC = storyboard?.instantiateViewControllerWithIdentifier("browserVC") as? BrowserViewController {
            browserVC.URL = wrappedURL
            navigationController?.pushViewController(browserVC, animated: true)
        }
    }
    
    func userDidClick(username: String?) {
        if let name = username {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let atUserButton = UIAlertAction(title: "@\(name)", style: .Default) {
                [unowned self, unowned alert] action in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let viewUserButton = UIAlertAction(title: "查看资料", style: .Default) {
                [unowned self, unowned alert] action in
                self.showUserVC(name)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
        
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel) {
                [unowned self, unowned alert] action in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alert.addAction(atUserButton)
            alert.addAction(viewUserButton)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'");
    }
    
    // MARK: ReplyTopicViewControllerDelegate
    
    func getTopicID() -> Int {
        return topicID
    }
    
    func didReplySucceed() {
        requestTopic()
    }
    
    func didReplyCancelWithDraft() {
        
    }
    
    // MARK: Bottom toolbar actions
    
    private func configureFavButton() {
        if topic?.isFavorited == true {
            favoriteButton.image = UIImage(named: "been_favorite_button")
        } else {
            favoriteButton.image = UIImage(named: "favorite_button")
        }
    }
    
    private func configureAppreciationButton() {
        if topic?.isAppreciated == true {
            appreciationButton.enabled = false
            appreciationButton.image = UIImage(named: "been_appreciation_button")
        }
    }
    
    @IBAction func appreciationButtonDidTouch(sender: UIBarButtonItem) {
        
        if !isLoggedIn {
            return
        }
        
        if let token = topic?.appreciateToken {
            showProgressView()
            SessionService.appreciateTopic(topicID, token: token) { [weak self] (error) in
                if error != nil {
                    self?.showError(error)
                } else {
                    self?.showSuccess(status: "已发送感谢")
                    self?.topic?.isAppreciated = true
                    self?.configureAppreciationButton()
                }
            }
        }
        
    }
   
    @IBAction func favoriteButtonDidTouch(sender: UIBarButtonItem) {
        
        showProgressView()
        if let favLink = topic?.favoriteLink {
            SessionService.favoriteTopic(favLink) { [weak self] (error) -> Void in
                if error != nil {
                    self?.showError(error)
                    return
                }
                
                // 为了可以正常取消收藏，所以需要 reload 一下 topic
                self?.requestTopic() { [weak self] in
                    if self?.topic?.isFavorited == true {
                        self?.showSuccess(status: "已收藏")
                    } else {
                        self?.showSuccess(status: "已取消收藏")
                    }
                }
            }
        }
    }

    @IBAction func previousPageButtonDidTouch(sender: UIBarButtonItem) {
    }
    
    
    @IBAction func nextPageButtonDidTouch(sender: UIBarButtonItem) {
    }
    
    @IBAction func refreshButtonDidTouch(sender: AnyObject) {
        requestTopic()
    }
    
    
    
}
