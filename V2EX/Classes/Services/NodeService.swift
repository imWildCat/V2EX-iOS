//
//  NodeService.swift
//  V2EX
//
//  Created by WildCat on 12/04/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation
import SwiftyJSON

class NodeService {
    
    static func getAll(response: ((error: ErrorType?, nodes: [Node]) -> Void)? = nil) {
        V2EXNetworking.get("api/nodes/all.json").response { (_, _, data, error) in
            
            var nodes = [Node]()
            
            if let jsonData = data {
                let json = JSON(data: jsonData)
                
                for (_, nodeJSON) in json {
                    if let nodeName = nodeJSON["title"].string, nodeSlug = nodeJSON["name"].string {
                        let newNode = Node(name: nodeName, slug: nodeSlug)
                        nodes.append(newNode)
                    }
                }
                
                response?(error: error, nodes: nodes)
            } else {
                
                response?(error: nil, nodes: nodes)
            }
            
        }
    }
    
}