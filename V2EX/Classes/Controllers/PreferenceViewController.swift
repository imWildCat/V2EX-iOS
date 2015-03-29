//
//  PreferenceViewController.swift
//  V2EX
//
//  Created by WildCat on 13/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

class PreferenceViewController: UIViewController {

    @IBOutlet weak var lbl: UILabel!
    override func viewDidLoad() {
        
        TopicSerivce.favoriteTopics(page: 1) { (error, topics, totalPage) -> Void in
            
        }
        
        lbl.text = "sdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sadsdaasadsa sdaas hsaasdsa sad"
    }
}
 