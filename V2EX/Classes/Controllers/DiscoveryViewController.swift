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
    
    var tabSlugs = [String]()
    var tabSettingChanged = false
    
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
        fetchTabData()
        setListViewControllers()
        
        // Set up pageViewController
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([topicListViewControllers.first!], direction: .Forward, animated: true, completion: nil)
        
        // Fix for contents under navigation bar for iOS 8
        fixForiOS8()
        
        setUpDoubleTapRecognizerForNavigationBar()
        
        setUpObservers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkIfTabSetingChanged()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        removeObservers()
    }
    
    private func fetchTabData() {
        do {
            let tabs = try Tab.fetchSortedList()
            
            var tabNames = [String]()
            tabSlugs = []
            for tab in tabs {
                tabSlugs.append(tab.slug)
                tabNames.append(tab.name)
            }
            tabSegmentedControl.sectionTitles = tabNames
            tabSettingChanged = false
        } catch _ as NSError {
            showError(status: "加载标签页设置时出错。")
        }
    }
    
    private func setUpObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tabSettingDidChange", name: TAB_SETTINGS_CHANGED_NOTIFICATION_KEY, object: nil)
    }
    
    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TAB_SETTINGS_CHANGED_NOTIFICATION_KEY, object: nil)
    }
    
    private func checkIfTabSetingChanged() {
        if tabSettingChanged {
            fetchTabData()
            
            setPage(0)
            tabSegmentedControl.setSelectedSegmentIndex(0, animated: true)
            
            setListViewControllers()
            
            pageViewController.setViewControllers([topicListViewControllers[0]], direction: .Forward, animated: false, completion: nil)
        }
    }
    
    @objc private func tabSettingDidChange() {
        tabSettingChanged = true
    }
    
    func setUpDoubleTapRecognizerForNavigationBar() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "navigationBarDoubleTap:")
        tapRecognizer.numberOfTapsRequired = 2
        navigationController?.navigationBar.addGestureRecognizer(tapRecognizer)
    }
    
    func navigationBarDoubleTap(recognizer: UIGestureRecognizer) {
        if let currentTabVC = topicListViewControllers[currentPage] as? TopicListViewController {
            currentTabVC.scrollToTopAndRefresh()
        }
    }
    
    func fixForiOS8() {
        guard #available(iOS 9, *) else {
            navigationController?.navigationBar.translucent = false
            return
        }
    }
    
    func setListViewControllers() {
        topicListViewControllers = []
        for slug in tabSlugs {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("topicListVC") as! TopicListViewController
            vc.tabSlug = slug
            topicListViewControllers.append(vc)
        }
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
