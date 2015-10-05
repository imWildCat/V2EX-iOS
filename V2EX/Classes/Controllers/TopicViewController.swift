//
//  TopicViewController.swift
//  V2EX
//
//  Created by WildCat on 15/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
import JTSImageViewController
import TUSafariActivity

class TopicViewController: UIViewController, UIWebViewDelegate, ReplyTopicViewControllerDelegate {
    
    // MARK: Vars
    
    enum Mode {
        case ReadTopic
        case NewTopic
    }
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var previousPageButton: UIBarButtonItem!
    @IBOutlet weak var pageNumberButton: UIBarButtonItem!
    @IBOutlet weak var nextPageButton: UIBarButtonItem!
    @IBOutlet weak var appreciationButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    @IBOutlet weak var webView: UIWebView!
//    var webView: WKWebView
    var mode = Mode.ReadTopic
    var topicID = 0
    var topic: Topic?
    var posts = [Reply]()
    var currentPage = 1
    var totalPage = 1
    
    // WebView(ScrollView) flag to detect scrolling direction
    var lastContentOffset: CGFloat = 0

    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
//        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        webView.backgroundColor = UIColor(red: 253/255, green: 248/255, blue: 234/255, alpha: 1)
        webView.opaque = false
        webView.delegate = self
        webView.scrollView.delegate = self
        
//        view.addSubview(webView)
//        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        let widthConstraint = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
//        view.addConstraint(widthConstraint)
//        let heightConstraint = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
//        view.addConstraint(heightConstraint)
        
        requestTopic()
    }
    
    // MARK: Popover Menu
    
    @IBAction func rightNavButtonDidTouched(sender: AnyObject) {
        var applicationActivities = [UIActivity]()
        
        _ = CustomActivity(title: "拷贝链接", image: UIImage(named: "copy_icon")!) { [unowned self] () -> Void in
            let urlString = "https://www.v2ex.com/t/\(self.topicID)"
            UIPasteboard.generalPasteboard().string = urlString
            
            self.showSuccess(status: "链接已复制")
        }
        let ignoringActivity = CustomActivity(title: "忽略主题", image: UIImage(named: "ignore_icon")!) { [unowned self] () -> Void in
            if self.isLoggedIn {
                self.showProgressView()
                SessionService.ignoreTopic(self.topicID) { [weak self] (error) in
                    if error != nil {
                        self?.showError(error)
                    } else {
                        self?.showSuccess(status: "忽略成功")
                    }
                }
            }
        }
        let reportingActivity = CustomActivity(title: "报告主题", image: UIImage(named: "report_icon")!) { [unowned self] () -> Void in
            if self.isLoggedIn {

                if self.topic?.isReported == true {
                    self.showError(status: "您已经报告过这个主题了")
                    return
                }
                
                if let rLink = self.topic?.reportLink {
                    self.showProgressView()
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
        let safariActivity = TUSafariActivity()
        
//        applicationActivities.append(copyingLinkActivity)
        applicationActivities.append(ignoringActivity)
        applicationActivities.append(reportingActivity)
        applicationActivities.append(safariActivity)
        
        if let url = NSURL(string: "https://www.v2ex.com/t/\(topicID)") {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: applicationActivities)
            presentViewController(activityVC, animated: true, completion: nil)
        }

    }
    
    // MARK: Networking
    
    func requestTopic(page: Int? = nil, finished: (() -> Void)? = nil) {
        let path = NSBundle.mainBundle().bundlePath
        let baseURL = NSURL.fileURLWithPath(path)
        
        if let newTopic = topic where mode == .NewTopic {
            webView.loadHTMLString(TopicViewModel.renderHTML(newTopic, replies: []), baseURL: baseURL)
            topicID = newTopic.id
            topic = nil
            return
        }
        
        showProgressView()
        TopicSerivce.singleTopic(topicID, page: page, response: { [weak self, finished] (error, fetchedTopic, replies, currentPage, totalPage)  in
            
            if error != nil {
                self?.showError(error)
            }
            
            self?.webView.loadHTMLString(TopicViewModel.renderHTML(fetchedTopic, replies: replies), baseURL: baseURL)
            self?.hideProgressView()
            self?.topicID = fetchedTopic.id
            self?.topic = fetchedTopic
            self?.posts = replies
            
            self?.currentPage = currentPage
            if let tp = totalPage {
                self?.totalPage = tp
            }
            
            self?.configureBottomToolbar()
   
            
            finished?()
        })
    }
    
    // MARK: WebView
    
    private func addAppreciatedPost(postID: String) {
        webView.stringByEvaluatingJavaScriptFromString("addAppreciatedPost(\"\(postID)\")")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'");
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let scheme = request.URL?.scheme {

            if scheme == "file" {
                return true
            }
            
            if scheme == "webview" {
                print(request.URLString)
                actionHanlder(request.URLString)
                return false
            }
        }
        
        return false
    }
    
    func actionHanlder(URL: String) {
        let (action, params) = URL.parseWebViewAction()
        switch action {
        case .OpenBrowser:
            openWebBrowser(params["url"])
        case .User:
            userDidClick(params["username"])
        case .ShowImage:
            showImage(params["url"])
        case .ShowPostActions:
            showPostActions(params["postID"])
        case .ShowTopic:
            if let id = Int(params["id"] ?? "") {
                showTopicVC(id)
            }
        case .OpenNode:
            if let topicListVC = storyboard?.instantiateViewControllerWithIdentifier("topicListVC") as? TopicListViewController, slug = params["slug"] {
                topicListVC.nodeSlug = slug
                topicListVC.mode = .Node
                navigationController?.pushViewController(topicListVC, animated: true)
            }
        default:
            break
        }
    }
    
    func openWebBrowser(URL: String?) {
        showWebBrowser(URL)
    }
    
    func userDidClick(username: String?) {
        if !isLoggedIn {
            return
        }
        
        if let name = username {
            showUserVC(name)
        }
    }
    
    private func getPost(id id: String) -> Reply? {
        if let intID = Int(id) {
            for post in posts {
                if intID == post.id {
                    return post
                }
            }
        }
        return nil
    }
    
    func showPostActions(postID: String?) {
        if let id = postID, post = getPost(id: id), intID = Int(id) {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let atUserButton = UIAlertAction(title: "@\(post.author.name)", style: .Default) {
                [unowned self, unowned alert] action in
                self.showReplyTopicVC("@\(post.author.name)")
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let viewUserButton = UIAlertAction(title: "查看资料", style: .Default) {
                [unowned self, unowned alert] action in
                self.showUserVC(post.author.name)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let appreciatingButton = UIAlertAction(title: "感谢", style: .Default) {
                [unowned self, unowned alert] action in
                SessionService.appreciateReply(intID, token: post.appreciatingReplyToken ?? ""){ [weak self] (error) -> Void in
                    if error != nil {
                        self?.showError(error)
                    } else {
                        self?.showSuccess(status: "已发送感谢")
                        self?.configureAppreciationButton()
                        self?.addAppreciatedPost(id)
                    }
                }
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel) {
                [unowned alert] action in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alert.addAction(atUserButton)
            alert.addAction(viewUserButton)
            alert.addAction(appreciatingButton)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func showImage(urlString: String?) {
        if let urlS = urlString, url = NSURL(string: urlS) {
            let imageInfo = JTSImageInfo()
            imageInfo.imageURL = url
            let imageVC = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
            imageVC.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOffscreen)
        }
    }
    
    // MARK: Reply
    
    func showReplyTopicVC(initialContent: String? = nil) {
        if !isLoggedIn {
            return
        }
        
        if let replyTopicVC = storyboard?.instantiateViewControllerWithIdentifier("replyTopicVC") as? ReplyTopicViewController {
            replyTopicVC.parentVC = self
            
            if let c = initialContent {
                replyTopicVC.initialContent = c
            }
            
            presentViewController(replyTopicVC, animated: true, completion: nil)
        } else {
            showError(status: "节点未定义，无法创建话题")
        }
    }
    
    // MARK: Navgation bar
    
    @IBAction func didReplyButtonTouch(sender: UIBarButtonItem) {
        showReplyTopicVC()
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
    
    private func configureBottomToolbar() {
        configureFavButton()
        configureAppreciationButton()
        configurePageButtons()
    }
    
    private func hideBottomBar() {
        UIView.animateWithDuration(0.35, delay: 0, options: .BeginFromCurrentState, animations: {
            self.bottomToolbar.alpha = 0
            }, completion: nil)
    }
    
    private func showBottomBar() {
        UIView.animateWithDuration(0.35, delay: 0, options: .BeginFromCurrentState, animations: {
            self.bottomToolbar.alpha = 1
            }, completion: nil)
    }
    
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
            
            addAppreciatedPost("0")
        }
    }
    
    private func configurePageButtons() {
        pageNumberButton.title = currentPage.description
        if totalPage == 1 {
            nextPageButton.enabled = false
            previousPageButton.enabled = false
        } else if totalPage > 1 {
            if currentPage == totalPage {
                previousPageButton.enabled = true
                nextPageButton.enabled = false
            } else if currentPage == 1 {
                previousPageButton.enabled = false
                nextPageButton.enabled = true
            } else {
                previousPageButton.enabled = true
                nextPageButton.enabled = true
            }
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
        if !isLoggedIn {
            return
        }
        
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
        requestTopic(--currentPage)
    }
    
    
    @IBAction func nextPageButtonDidTouch(sender: UIBarButtonItem) {
        requestTopic(++currentPage)
    }
    
    @IBAction func refreshButtonDidTouch(sender: AnyObject) {
        requestTopic()
    }
    
}

extension TopicViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        defer {
            lastContentOffset = scrollView.contentOffset.y
        }
        
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottomEdge > scrollView.contentSize.height {
            // If scroll view will rebound, return
            return
        }
        
        if scrollView.contentOffset.y > lastContentOffset && scrollView.contentOffset.y > -32  {
            hideBottomBar()
        } else if scrollView.contentOffset.y < lastContentOffset {
            showBottomBar()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottomEdge >= scrollView.contentSize.height {
            // At the end
            hideBottomBar()
        }
    }
}
