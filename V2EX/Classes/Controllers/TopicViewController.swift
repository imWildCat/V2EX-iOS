//
//  TopicViewController.swift
//  V2EX
//
//  Created by WildCat on 21/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

class TopicViewController: UITableViewController {
    
    private lazy var _cellCache = NSCache()
    private lazy var _imageSizeCache = NSCache()
    lazy var reloadCellKeyCache = NSCache()
    
    var topicId: Int = 0
    var topic = Topic(id: nil, title: nil, node: nil, author: nil)
    var replies = [Reply]()
    
    override func viewDidLoad() {
        load()
    }
    
    func load() {
        showProgressView()
        TopicSerivce.singleTopic(topicId, response: { [unowned self] (error, topic, replies) in
            if error == nil {
                self.topic = topic
                self.replies = replies
                
                println(topic.title)
                println(replies.count)
                self.tableView.reloadData()
            }
            self.hideProgressView()
        })
    }
    
    // FIXME: Unable to simultaneously satisfy constraints.
    /*
    Probably at least one of the constraints in the following list is one you don't want. Try this: (1) look at each constraint and try to figure out which you don't expect; (2) find the code that added the unwanted constraint or constraints and fix it. (Note: If you're seeing NSAutoresizingMaskLayoutConstraints that you don't understand, refer to the documentation for the UIView property
    */
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // the following line cannot fix the bug above:
        tableView.reloadData()
//
//        _cellCache.removeAllObjects()
//        _imageSizeCache.removeAllObjects()
        
//        println("test")
    }
    
    
//    // MARK: content link / image pushed
//    func linkPushed(button: DTLinkButton) {
//        let URL = button.URL
//        
//        println("link pushed " + URL.URLString)
//    }
//    
//    func linkLongPressed(gesture: UILongPressGestureRecognizer) {
//        if gesture.state == UIGestureRecognizerState.Began {
//            if let button = gesture.view as DTLinkButton? {
//                button.highlighted = false
//                
//                // TODO: xxx
//                
//                println("link long pressed")
//            }
//        }
//    }
    
    
    
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if topic.id != 0 {
            return replies.count + 2
        }
        return 0
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        return tableview(tableView, preparedCellForIndexPath: indexPath)
        return tableview(tableView, preparedCellForIndexPath: indexPath)
    }
    
     func tableview(tableView: UITableView, preparedCellForIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let topicTitleCellViewModel = TopicTitleCellViewModel(topic: topic)
            let cell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as TopicTitleCell
            cell.render(topicTitleCellViewModel);
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as TopicContentCell
            var contentViewModel: TopicContentCellViewModel!
            if indexPath.row == 1 {
                contentViewModel = TopicContentCellViewModel(topic: topic)
            } else {
                println(indexPath.row)
                contentViewModel = TopicContentCellViewModel(reply: replies[indexPath.row - 2])
            }
            cell.render(contentViewModel)
            
            
            let key: AnyObject? = reloadCellKeyCache.objectForKey(indexPath.row)
            if indexPath.row == 1 && key == nil {
                
                
                dispatch_after(2, dispatch_get_main_queue(), { [weak self] in
                    if let selfVC = self {
//                        selfVC.tableView.beginUpdates()
//                       selfVC.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//                        selfVC.tableView.endUpdates()
                        selfVC.reloadCellKeyCache.setObject(indexPath.row, forKey: indexPath.row)
                    }
                    
                    println("reload 1")
                })
            }
            
            return cell
        }
    }
    
    
    
    func tableview(tableView: UITableView, oldpreparedCellForIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let topicTitleCellViewModel = TopicTitleCellViewModel(topic: topic)
            let cell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as TopicTitleCell
            cell.render(topicTitleCellViewModel)
            return cell
        }
        
        let cacheKey = NSString(format: "cell_pid_%ld", indexPath.row)
        
        var cell: TopicContentCell? = _cellCache.objectForKey(cacheKey) as TopicContentCell?
        
        if cell == nil {
            cell = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as? TopicContentCell
            _cellCache.setObject(cell!, forKey: cacheKey)
            
            var topicContentCellViewModel: TopicContentCellViewModel
            if indexPath.row == 1 {
                topicContentCellViewModel = TopicContentCellViewModel(topic: topic)
            } else {
                topicContentCellViewModel = TopicContentCellViewModel(reply: replies[indexPath.row - 2])
            }
//            cell?.reloadCellBlock = { [weak self] () -> Void in
//                if let parentVC = self {
//                    //                self.tableView.beginUpdates()
////                    parentVC.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
//                    //                self.tableView.endUpdates()
//
//                }
//
//                println("Reload row: " + indexPath.row.description)
//            }
//            cell?.attributedTextContentView.delegate = self
            cell?.render(topicContentCellViewModel)
        }
//        if let textAttachments = cell?.attributedLabel.layoutFrame?.textAttachments() as? [DTTextAttachment] {
//            for oneAttachment in textAttachments {
//                if let sizeValue = _imageSizeCache.objectForKey(oneAttachment.contentURL) as NSValue? {
//                    cell?.attributedLabel.layouter = nil
//                    oneAttachment.displaySize = sizeValue.CGSizeValue()
//                }
//                
//            }
//        }
        
//        cell?.setNeedsDisplay()
//        cell?.attributedLabel.relayoutText()

        

        return cell!;
    }
    
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let cell = tableview(tableView, preparedCellForIndexPath: indexPath) as TopicContentCell
//        let neededSize = cell.attributedTextContentView.suggestedFrameSizeToFitEntireStringConstraintedToWidth(cell.attributedTextContentView.frame.width)
//        return neededSize.height
//    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
    }
    
    
    

}
