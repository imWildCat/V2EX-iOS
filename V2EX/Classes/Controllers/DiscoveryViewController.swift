//
//  DiscoveryViewController.swift
//  V2EX
//
//  Created by WildCat on 12/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

class DiscoveryViewController: UIViewController {

    @IBOutlet weak var tabSegmentedControl: HMSegmentedControl!
    @IBOutlet weak var paginatedView: CatPaginatedScrollView!
    
//    let tabs = [
//        ["name": "全部",  "slug": "all"],
//        ["name": "最热",  "slug": "hot"],
//        ["name": "R2" ,  "slug": "r2"],
//        ["name": "技术",  "slug": "tech"],
//        ["name": "创意",  "slug": "creative"],
//        ["name": "好玩",  "slug": "play"],
//        ["name": "Apple","slug": "apple"],
//        ["name": "酷工作","slug": "jobs"],
//        ["name": "交易",  "slug": "deals"],
//        ["name": "城市",  "slug": "city"],
//    ]
    
    let slugs = ["all", "hot", "r2", "qna", "tech", "creative", "play", "apple", "jobs", "deals", "city"]
    
    var topicListViewControllers = Dictionary<String, TopicListViewController>()
//    lazy var allTopicsListVC: TopicListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("topicListVC") as TopicListViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabSegmentedControl.setUp()
        tabSegmentedControl.indexChangeBlock = { [unowned self] in self.didTabSegmentedControlIndexChanged($0) }
        
        paginatedView.didPageIndexChanged = { [unowned self] in self.didPageIndexChanged($0) }
        setUpListViewControllers()
    }
    
    func setUpListViewControllers() {
        self.storyboard!.instantiateViewControllerWithIdentifier("topicListVC")
        for slug in slugs {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("topicListVC") as TopicListViewController!
            vc.tabSlug = slug
            topicListViewControllers[slug] = vc
            paginatedView.addPage(vc)
        }
        

//        println(topicListViewControllers)
//        for tab in tabs {
//            let slug = tab["slug"]
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopicVC" {
            let destinationViewController = segue.destinationViewController as TopicViewController
            let topic = sender as Topic
            destinationViewController.topicId = topic.id
            println("topic")
        }
    }
    
    func didTabSegmentedControlIndexChanged(index: Int) {
//        println(index)
        paginatedView.jumpToPage(index)
    }
    
    func didPageIndexChanged(index: Int) {
        self.tabSegmentedControl.setSelectedSegmentIndex(UInt(index), animated: true)
    }
    
}
