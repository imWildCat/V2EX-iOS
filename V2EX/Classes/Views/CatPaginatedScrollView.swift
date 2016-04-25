//
//  CatPaginatedScrollView.swift
//
//  Created by WildCat on 04/10/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

class CatPaginatedScrollView: UIScrollView, UIScrollViewDelegate {
    var previousPageCount = 0
    
    var didPageIndexChanged: ((pageIndex: Int) -> ())?
    
    private lazy var controllers = [UIViewController]()
    
    // Disable tap:
    // private lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
    
    var jumping: Bool = false
    private var isJumping: Bool {
        get {
            return jumping
        }
    }
    
    var currentPage: Int {
        get {
            return Int(round(contentOffset.x / frame.size.width))
        }
    }
    
    var nextPage: Int {
        get {
            return currentPage + 1
        }
    }
    
    var lastPage: Int {
        get {
            return numberOfPages - 1
        }
    }
    
    var numberOfPages: Int {
        get {
            return controllers.count
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        pagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
//        round(contentOffset.x / (frame.size.width / 2))
        
//        addGestureRecognizer(tapGestureRecognizer)
        
        delegate = self
    }
    
//    func handleTap(recognizer: UITapGestureRecognizer) {
//        jumpToPage(nextPage, bounce: 0, completion: nil)
//    }
    

    func addPage(viewController: UIViewController) {
        let pageView = viewController.view
        pageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageView)
        
        let topConstraint = NSLayoutConstraint(item: pageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        var leftContraint: NSLayoutConstraint?
        let widthConstraint = NSLayoutConstraint(item: pageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: pageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        
        if numberOfPages > 0 {
            let previousPage = controllers[numberOfPages - 1].view
            leftContraint = NSLayoutConstraint(item: pageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: previousPage, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        } else {
            leftContraint = NSLayoutConstraint(item: pageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        }
        
        addConstraints([topConstraint, leftContraint!, widthConstraint, heightConstraint])
        
        controllers.append(viewController)
    }

    
    override func layoutSubviews() {
        if contentSize.width != frame.size.width * CGFloat(numberOfPages) {
            contentSize = CGSize(width: frame.size.width * CGFloat(numberOfPages), height: contentSize.height)
            contentOffset = CGPoint(x: frame.width * CGFloat(previousPageCount), y: contentOffset.y)
        } else {
            previousPageCount = currentPage
        }
        super.layoutSubviews()
    }
    
    func jumpToPage(page: Int, var bounce: CGFloat, completion:(() -> Void)?) {
        if !isJumping && page < numberOfPages {
            jumping = true
            
            pagingEnabled = false
            if frame.size.width * CGFloat(page) < contentOffset.x {
                bounce = -bounce
            }
            
            UIView.animateWithDuration(0.35, animations: { [unowned self] () -> Void in
                self.contentOffset = CGPoint(x: self.frame.size.width * CGFloat(page) + bounce, y: self.contentOffset.y)
            }, completion: { [unowned self] (finished) -> Void in
                UIView.animateWithDuration(1, animations: { () -> Void in
                    self.contentOffset = CGPoint(x: self.contentOffset.x - bounce, y: self.contentOffset.y)
                }, completion: { [unowned self] (finished) -> Void in
                    self.jumping = false
                    self.pagingEnabled = true
                    if (completion != nil) {
                        completion!()
                    }
                })
            })
            
        }
    }
    
    func jumpToPage(page: Int) {
        jumpToPage(page, bounce: 0, completion: nil)
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didPageIndexChanged?(pageIndex: currentPage)
    }
    
  
    
    
}
