//
//  NodeSearchViewController.swift
//  V2EX
//
//  Created by WildCat on 12/04/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//
//  Ref: http://www.raywenderlich.com/76519/add-table-view-search-swift

import UIKit

class NodeSearchViewController: UITableViewController, UISearchResultsUpdating {
    
    var resultSearchController = UISearchController()
    
    var nodes = [Node]()
    
    var filteredNodes = [Node]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(red: 253/255, green: 248/255, blue: 234/255, alpha: 1)
        
        loadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        // FIXME: hide search bar when this VC disappeared
        // Not working:
//        Utils.delay(0.2) { [weak self] in
//            self?.resultSearchController.active = false
//        }
    }
    
    func loadData() {
        showProgressView()
        
        NodeService.getAll { [weak self](error, nodes) in
            if error != nil {
                self?.showError(.Networking)
            } else {
                self?.nodes = nodes
                self?.tableView.reloadData()
                
                self?.hideProgressView()
            }
        }
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredNodes = nodes.filter({ (node: Node) -> Bool in
            let nameMatch = node.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            
            let slugMatch = node.slug.lowercaseString.rangeOfString(searchText.lowercaseString)
            
            return nameMatch != nil || slugMatch != nil
        })
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredNodes.removeAll(keepCapacity: false)
        
        filterContentForSearchText(searchController.searchBar.text)
        
        self.tableView.reloadData()
    }
    
    
    
    // MARK: UITAbleViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return filteredNodes.count
        } else {
            return nodes.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        var node: Node
        
        if resultSearchController.active {
            node = filteredNodes[indexPath.row]
        } else {
            node = nodes[indexPath.row]
        }

       
        cell.textLabel?.text = node.name
        
        return cell
    }
    
    // MARK: segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopicListVC" {
            let destinationViewController = segue.destinationViewController as! TopicListViewController
            
            if let index = tableView.indexPathForSelectedRow()?.row {
            
                var node: Node
                if resultSearchController.active {
                    node = filteredNodes[index]
                } else {
                    node = nodes[index]
                }
                destinationViewController.nodeSlug = node.slug
                
//                resultSearchController.active = false
                Utils.delay(0.2) { [weak self] in
                    self?.resultSearchController.active = false
                }
            }
        }
    }
    
}
