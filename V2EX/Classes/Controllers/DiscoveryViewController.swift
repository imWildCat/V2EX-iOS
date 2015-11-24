//
//  DiscoveryViewController.swift
//  V2EX
//
//  Created by WildCat on 12/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit
import HMSegmentedControl

class DiscoveryViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    @IBOutlet weak var tabSegmentedControl: HMSegmentedControl!
    
    let slugs = ["all", "hot", "r2", "qna", "tech", "creative", "play", "apple", "jobs", "deals", "city"]
    
    var pageViewController: UIPageViewController!
    
    var topicListViewControllers = [UIViewController]()
    
    var currentPage = 0
    
//    lazy var allTopicsListVC: TopicListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("topicListVC") as TopicListViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabSegmentedControl.setUp()
        tabSegmentedControl.indexChangeBlock = { [unowned self] (index) in
            self.setPage(index)
        }
        setUpListViewControllers()
        
        // Set up pageViewController
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([topicListViewControllers.first!], direction: .Forward, animated: true, completion: nil)
        
        // Fix for contents under navigation bar for iOS 8
        fixForiOS8()
    }
    
    func fixForiOS8() {
        guard #available(iOS 9, *) else {
            navigationController?.navigationBar.translucent = false
            return
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AVAnalytics.beginLogPageView("DiscoveryViewController")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AVAnalytics.endLogPageView("DiscoveryViewController")
    }
    
    func setUpListViewControllers() {
        self.storyboard!.instantiateViewControllerWithIdentifier("topicListVC")
        for slug in slugs {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("topicListVC") as! TopicListViewController
            vc.tabSlug = slug
            topicListViewControllers.append(vc)
//            paginatedView.addPage(vc)
        }
        

//        println(topicListViewControllers)
//        for tab in tabs {
//            let slug = tab["slug"]
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopicVC" {
            let destinationViewController = segue.destinationViewController as! TopicViewController
            let topic = sender as! Topic
            destinationViewController.topicID = topic.id
        } else if segue.identifier == "loadPageVC" {
            pageViewController = segue.destinationViewController as! UIPageViewController
            
        }
    }
    
    func didPageIndexChanged(index: Int) {
        self.tabSegmentedControl.setSelectedSegmentIndex(UInt(index), animated: true)
    }
    
    // MARK: Custom pageVC method
    func setPage(index: Int) {
        if index > currentPage {
            pageViewController.setViewControllers([topicListViewControllers[index]], direction: .Forward, animated: true, completion: nil)
        } else if index < currentPage {
            pageViewController.setViewControllers([topicListViewControllers[index]], direction: .Reverse, animated: true, completion: nil)
        }
        currentPage = index
    }
    
    // MARK: UIPageViewControllerDelegate
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        
        let vc = pageViewController.viewControllers?[0] as! TopicListViewController
        let index = topicListViewControllers.indexOf(vc)!
        
        currentPage = index
        
        tabSegmentedControl.setSelectedSegmentIndex(UInt(index), animated: true)
    }
    
    
    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = topicListViewControllers.indexOf(viewController)!
        if index == 0 {
            return nil
        } else {
            return topicListViewControllers[index - 1]
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = topicListViewControllers.indexOf(viewController)!
        if index == topicListViewControllers.count - 1 {
            return nil
        } else {
            return topicListViewControllers[index + 1]
        }
    }
    
}
