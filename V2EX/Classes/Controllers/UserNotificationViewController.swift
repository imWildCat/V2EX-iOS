//
//  UserNotificationViewController.swift
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class UserNotificationViewController: UITableViewController {

    override func viewDidLoad() {
        NotificationService.get()
    }

}