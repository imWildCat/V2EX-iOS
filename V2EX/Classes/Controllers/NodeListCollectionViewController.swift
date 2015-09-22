//
//  NodeListCollectionViewController.swift
//  V2EX
//
//  Created by WildCat on 9/12/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

let reuseCellIdentifier = "NodeNameCell"
let reuseHeaderIdentifier = "NodeCategoryNameView"

class NodeListCollectionViewController: UICollectionViewController {
    
    // Search bar propreties:
    var searchBar: UISearchBar?
    var searchBarActive = false
    var searchBarBoundsY: CGFloat = 0
    
    var nodeList: NSArray!
    
    var allNodes = [Node]()
    var filteredNodes = [Node]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nodeList = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("default_nodes", ofType: "plist") ?? "") ?? NSArray()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        loadNodeData()
    }
    
    override func viewWillAppear(animated: Bool) {
        addSearchBar()
    }
    
    private func itemForIndexPath(indexPath: NSIndexPath) -> NSDictionary {
        if let sectionData = nodeList.objectAtIndex(indexPath.section) as? NSDictionary, children = sectionData.valueForKey("children") as? NSArray, item = children.objectAtIndex(indexPath.row) as? NSDictionary {
            return item
        }
        return NSDictionary()
    }
    
    private func itemNameForIndexPath(indexPath: NSIndexPath) -> String {
        return (itemForIndexPath(indexPath).objectForKey("name") as? String) ?? ""
    }
    
    private func itemSlugForIndexPath(indexPath: NSIndexPath) -> String {
        return (itemForIndexPath(indexPath).objectForKey("slug") as? String) ?? ""
    }
    
    // MARK: Searching for all nodes
    
    private func loadNodeData() {
        NodeService.getAll { [weak self] (error, nodes) in
            if error != nil {
                self?.showError()
            } else {
                self?.allNodes = nodes
                self?.hideProgressView()
                NSLog("data loaded: \(nodes.count)")
            }
        }
    }
    
    private func filterContentForSearchText(searchText: String) {
        filteredNodes = allNodes.filter({ (node: Node) -> Bool in
            let nameMatch = node.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            
            let slugMatch = node.slug.lowercaseString.rangeOfString(searchText.lowercaseString)
            
            return nameMatch != nil || slugMatch != nil
        })
    }
    
    // MARK: segue
    
    private func presentTopicListViewController(nodeSlug: String?) {
        if let slug = nodeSlug {
            performSegueWithIdentifier("showTopicListVC", sender: slug)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopicListVC" {
            let destinationViewController = segue.destinationViewController as! TopicListViewController
            destinationViewController.nodeSlug = sender as? String
        }
    }
    
}

// MARK: UICollectionViewDataSource
extension NodeListCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if searchBarActive {
            NSLog("filtered count: \(filteredNodes.count)")
            return 1;
        }
        return nodeList.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBarActive {
            return filteredNodes.count
        } else {
            if let sectionData = nodeList.objectAtIndex(section) as? NSDictionary, children = sectionData.valueForKey("children") as? NSArray {
                return children.count
            }
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellIdentifier, forIndexPath: indexPath) as! NodeNameCollectionViewCell
        
        if searchBarActive {
            print("\(filteredNodes.count) - \(indexPath.row)")
            cell.nodeNameLabel.text = filteredNodes[indexPath.row].name
        } else {
            cell.nodeNameLabel.text = itemNameForIndexPath(indexPath)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseHeaderIdentifier, forIndexPath: indexPath) as! NodeCategoryNameCollectionReusableView
            if searchBarActive {
                headerView.nodeCategoryNameLabel.text = "搜索："
            } else {
                if let sectionData = nodeList.objectAtIndex(indexPath.section) as? NSDictionary, categoryName = sectionData.objectForKey("category") as? String {
                    headerView.nodeCategoryNameLabel.text = categoryName
                }
            }
            if indexPath.section == 0 {
                let oldFrame = headerView.frame
                let newFrame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: 88)
                headerView.frame = newFrame
            }
            return headerView
        default:
            NSLog("Not found kind \(kind)")
            return UICollectionReusableView()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension NodeListCollectionViewController {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var name: NSString!
        if searchBarActive {
            name = filteredNodes[indexPath.row].name as NSString
        } else {
            name = itemNameForIndexPath(indexPath) as NSString
        }
        
        let attributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16.0)!
            ] as [String: AnyObject]
        var size = name.sizeWithAttributes(attributes)
        size.width += 12
        size.height += 6
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 5 + 44, left: 10, bottom: 5, right: 10)
        }
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3.0
    }
}

// MARK: UICollectionViewDelegate
extension NodeListCollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var slug: String!
        if searchBarActive {
            slug = filteredNodes[indexPath.row].slug
        } else {
            slug = itemSlugForIndexPath(indexPath)
        }
        presentTopicListViewController(slug)
    }
}

extension NodeListCollectionViewController: UISearchBarDelegate {
    
    private func addSearchBar() {
        if let navBarHeight = navigationController?.navigationBar.frame.size.height where searchBar == nil {
            searchBarBoundsY = navBarHeight + UIApplication.sharedApplication().statusBarFrame.size.height
            searchBar = UISearchBar(frame: CGRect(x: 0, y: searchBarBoundsY, width: UIScreen.mainScreen().bounds.size.width, height: 44))
            searchBar?.searchBarStyle = UISearchBarStyle.Minimal
            searchBar?.tintColor = UIColor.whiteColor()
            searchBar?.barTintColor = UIColor.whiteColor()
            searchBar?.backgroundColor = UIColor.darkGrayColor()
            searchBar?.delegate = self
            searchBar?.placeholder = "搜索节点..."
            
            // Ref: http://stackoverflow.com/questions/24136874/appearancewhencontainedin-in-swift
            UITextField.v2_appearanceWhenContainedIn(UISearchBar.self).textColor = UIColor.whiteColor()
            
            addObservers()
        }
        
        if let sb = searchBar, i = searchBar?.isDescendantOfView(view) where !i {
            view.addSubview(sb)
        }
    }
    
    private func addObservers() {
        collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old], context: nil)
    }
    
    private func removeObservers() {
        collectionView?.removeObserver(self, forKeyPath: "contentOffset", context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let collectionView = object as? UICollectionView where keyPath == "contentOffset" {
            if let sb = searchBar {
                let x = sb.frame.origin.x
                let y = searchBarBoundsY + ((-1 * collectionView.contentOffset.y) - searchBarBoundsY)
                let width = sb.frame.size.width
                let height = sb.frame.size.height
                searchBar?.frame = CGRect(x: x, y: y, width: width, height: height)
            }
        }
    }
    
    private func cancelSearching() {
        searchBarActive = false
        searchBar?.resignFirstResponder()
        searchBar?.text = ""
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            searchBarActive = true
            filterContentForSearchText(searchText)
        } else {
            searchBarActive = false
        }
        collectionView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        cancelSearching()
        collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBarActive = true
        view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBarActive = false
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
