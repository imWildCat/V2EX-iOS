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
        
        println(tableView)
        
        loadData()
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
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredNodes = nodes.filter({ (node: Node) -> Bool in
            let stringMatch = node.name.lowercaseString.rangeOfString(searchText.lowercaseString)
            
            return stringMatch != nil
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

            }
        }
    }
    
}