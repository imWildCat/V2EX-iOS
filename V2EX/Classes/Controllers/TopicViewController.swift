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
    
    @IBOutlet weak var webViewBottomConstraint: NSLayoutConstraint!
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AVAnalytics.beginLogPageView("TopicViewController")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AVAnalytics.endLogPageView("TopicViewController")
    }
    
    // MARK: Popover Menu
    
    @IBAction func rightNavButtonDidTouched(sender: AnyObject) {
        var applicationActivities = [UIActivity]()
        
        _ = CustomActivity(title: "拷贝链接", image: UIImage(named: "copy_icon")!) { [unowned self] () -> Void in
            let urlString = "https://www.v2ex.com/t/\(self.topicID)"
            UIPasteboard.generalPasteboard().string = urlString
            
            self.showSuccessMessage("链接已复制")
        }
        let ignoringActivity = CustomActivity(title: "忽略主题", image: UIImage(named: "ignore_icon")!) { [unowned self] () -> Void in
            if self.isLoggedIn {
                self.showProgressView()
                SessionService.ignoreTopic(self.topicID) { [weak self] (result) in
                    self?.hideProgressView()
                    switch result {
                    case .Failure(_, let error):
                        self?.showError(error)
                    case .Success(_):
                        self?.showSuccessMessage("忽略成功")
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
                    SessionService.reportTopic(rLink) { [weak self] (result) -> Void in
                        self?.hideProgressView()
                        switch result {
                        case .Failure(_, let error):
                            self?.showError(error)
                        case .Success(_):
                            self?.showSuccessMessage("你已对本主题进行了报告")
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
//            activityVC.completionWithItemsHandler = { string, b, a, e in
//            }
            activityVC.excludedActivityTypes = [UIActivityTypeMail, UIActivityTypeMessage]
            presentViewController(activityVC, animated: true, completion: nil)
        }

    }
    
    // MARK: Networking
    
    func requestTopic(shouldReloadWebview: Bool = true, page: Int? = nil, finished: (() -> Void)? = nil) {
        let path = NSBundle.mainBundle().bundlePath
        let baseURL = NSURL.fileURLWithPath(path)
        
        if let newTopic = topic where mode == .NewTopic {
            webView.loadHTMLString(TopicViewModel.renderHTML(newTopic, replies: []), baseURL: baseURL)
            topicID = newTopic.id
            topic = nil
            return
        }
        
        showProgressView()
        TopicSerivce.singleTopic(topicID, page: page, response: { [weak self, finished] (result)  in
            self?.hideProgressView()
            if result.isFailure {
                self?.showError(result.error)
                return
            }
            
            if let topicPage = result.value {
                if shouldReloadWebview {
                    self?.webView.loadHTMLString(TopicViewModel.renderHTML(topicPage.topic, replies: topicPage.replies), baseURL: baseURL)
                }
                self?.topicID = topicPage.topic.id
                self?.topic = topicPage.topic
                self?.posts = topicPage.replies
                
                self?.currentPage = topicPage.currentPage
                self?.totalPage = topicPage.totalPage
                self?.configureBottomToolbar()
            }
            
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
        if let u = URL {
            showWebBrowser(u)
        }
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if let id = postID, intID = Int(id) {
            
            if let post = getPost(id: id) {
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
                    SessionService.appreciateReply(intID, token: post.appreciatingReplyToken ?? ""){ [weak self] (result) in
                        switch result {
                        case .Failure(_, let error):
                            self?.showError(error)
                        case .Success(_):
                            self?.showSuccessMessage("已发送感谢")
                            self?.configureAppreciationButton()
                            self?.addAppreciatedPost(id)
                        }
                    }
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
                alert.addAction(atUserButton)
                alert.addAction(viewUserButton)
                alert.addAction(appreciatingButton)
            } else {
                let viewUserButton = UIAlertAction(title: "查看资料", style: .Default) {
                    [unowned self, unowned alert] action in
                    if let username = self.topic?.author?.name {
                       self.showUserVC(username)
                    }
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
                alert.addAction(viewUserButton)
            }
            
            let copyButton = UIAlertAction(title: "复制", style: .Default, handler: {
                [unowned self] action in
                self.copyPost(intID)
                self.showSuccessMessage("已复制")
            })
           
            alert.addAction(copyButton)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel) {
            [unowned alert] action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func copyPost(id: Int) {
        
        func html2String(html: String?) -> String? {
            // TODO: better transformation
            return html?.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        }
        
        let pasteboard = UIPasteboard.generalPasteboard()
        if id == 0 {
            pasteboard.string = html2String(topic?.content)
        } else {
            for post in posts {
                if post.id == id {
                    pasteboard.string = html2String(post.content)
                    break
                }
            }
        }
    }
    
    func showImage(urlString: String?) {
        if let urlString = urlString, url = NSURL(string: urlString) {
            let imageInfo = JTSImageInfo()
            imageInfo.imageURL = url
            let imageVC = TopicImageViewController(imageInfo: imageInfo, mode: .Image, backgroundStyle: .Blurred)
            imageVC.showFromViewController(self, transition: .FromOffscreen)
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
        webViewBottomConstraint.constant = 0.0
        UIView.animateWithDuration(0.35, delay: 0, options: .BeginFromCurrentState, animations: {
            self.bottomToolbar.alpha = 0
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    private func showBottomBar() {
        webViewBottomConstraint.constant = 44.0
        UIView.animateWithDuration(0.35, delay: 0, options: .BeginFromCurrentState, animations: {
            self.bottomToolbar.alpha = 1
            self.view.layoutIfNeeded()
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
            SessionService.appreciateTopic(topicID, token: token) { [weak self] (result) in
                switch result {
                case .Failure(_, let error):
                    self?.showError(error)
                case .Success(_):
                    self?.showSuccessMessage("已发送感谢")
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
            SessionService.favoriteTopic(favLink) { [weak self] (result) -> Void in
                self?.hideProgressView()
                switch result {
                case .Failure(_, let error):
                    self?.showError(error)
                case .Success(_):
                    // 为了可以正常取消收藏，所以需要 reload 一下 topic
                    self?.requestTopic(false) { [weak self] in
                        if self?.topic?.isFavorited == true {
                            self?.showSuccessMessage("已收藏")
                        } else {
                            self?.showSuccessMessage("已取消收藏")
                        }
                    }
                }
            }
        }
    }

    @IBAction func previousPageButtonDidTouch(sender: UIBarButtonItem) {
        currentPage -= 1
        requestTopic(page: currentPage)
    }
    
    
    @IBAction func nextPageButtonDidTouch(sender: UIBarButtonItem) {
        currentPage += 1
        requestTopic(page: currentPage)
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
//            hideBottomBar()
        } else {
        }
        if scrollView.contentSize.height - bottomEdge == 44 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            scrollView.setContentOffset(bottomOffset, animated: true)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.45 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), { [unowned self] in
                self.showBottomBar()
            })
            
        }
//        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
//        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }
}
