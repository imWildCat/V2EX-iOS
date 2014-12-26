//
//  UIViewControllerExtension.swift
//  V2EX
//
//  Created by WildCat on 13/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @IBAction func sideMenuButtonTouched(sender: UIBarButtonItem) {
        RootViewController.displaySideMenu()
    }

    // MARK: KVNProgressUI
    private func setupBaseProgressUI() {
        KVNProgress.appearance().statusColor = UIColor.darkGrayColor()
        KVNProgress.appearance().statusFont = UIFont.systemFontOfSize(17.0)
        KVNProgress.appearance().circleStrokeForegroundColor = UIColor.darkGrayColor()
        KVNProgress.appearance().circleStrokeBackgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.3)
        KVNProgress.appearance().backgroundFillColor = UIColor(white: 0.9, alpha: 0.9)
        KVNProgress.appearance().backgroundTintColor = UIColor.whiteColor()
        KVNProgress.appearance().successColor = UIColor.darkGrayColor()
        KVNProgress.appearance().errorColor = UIColor.darkGrayColor()
        KVNProgress.appearance().circleSize = 75.0
        KVNProgress.appearance().lineWidth = 2.0
    }
    
    func showProgressView() {
        KVNProgress.show()
    }
    
    func hideProgressView() {
        KVNProgress.dismiss()
    }
    
}
