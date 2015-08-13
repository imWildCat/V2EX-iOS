//
//  UserInfoView.swift
//  V2EX
//
//  Created by WildCat on 7/31/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

@IBDesignable class UserInfoView: UIView {
    
    enum Mode {
        case CurrentUser
        case OtherUser
    }
    
    var mode = Mode.CurrentUser
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var regDateLabel: UILabel!
    @IBOutlet weak var livenessLabel: UILabel!
    @IBOutlet weak var dailyRedeemButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        commonInit()
    }
    
    func commonInit() {
//        hideDailyRedeemButton()
    }
    
    // Ref: http://iphonedev.tv/blog/2014/12/15/create-an-ibdesignable-uiview-subclass-with-code-from-an-xib-file-in-xcode-6
    private func xibSetup() {
        let view = loadViewFromNib()
        
        view.frame = bounds
        
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "UserInfoView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
}
