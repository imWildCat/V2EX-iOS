//
//  TopicContentCell.swift
//  V2EX
//
//  Created by WildCat on 09/01/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class TopicContentCell: UITableViewCell, DTAttributedTextContentViewDelegate {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var attributedTextContentView: DTAttributedTextContentView!
    var reloadCellBlock: (() -> ())?
    

    override func awakeFromNib() {
        selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    func render(viewModel: TopicContentCellViewModel) {
        
        avatarImageView.sd_setImageWithURL(NSURL(string: viewModel.avatarURL), placeholderImage: UIImage(named: "node_icon"))
        authorNameLabel.text = viewModel.authorName
        timeAgoLabel.text = viewModel.timeAgo
        
        // content
        attributedTextContentView.delegate = self
        attributedTextContentView.attributedString = TopicContentCell.HTML2AttrString(viewModel.contentHTML)
        
        setNeedsLayout()
//        setNeedsDisplay()
    }
    
    class func HTML2AttrString(HTML: String) -> NSAttributedString {
        if let data = HTML.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            if let attrString = NSAttributedString(HTMLData: data, options: [
                "DTDefaultFontSize": "14",
                "DTDefaultLinkDecoration": false
                ], documentAttributes: nil) {
                return attrString
            }
        }
        NSLog("Cannot init data from html, and then to NSAttributedString")
        return NSAttributedString(string: HTML)
    }
    
    // MARK: overrides

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let neededContentHeight = attributedTextContentView.suggestedFrameSizeToFitEntireStringConstraintedToWidth(contentView.frame.size.width).height
        let oldFrame = attributedTextContentView.frame
        let textViewFrame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.size.width, height: neededContentHeight)
        attributedTextContentView.frame = textViewFrame
    }
    
    
    // MARK: content link / image pushed
    func linkPushed(button: DTLinkButton) {
        let URL = button.URL
        
        println("link pushed " + URL.URLString)
    }
    
    func linkLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Began {
            if let button = gesture.view as DTLinkButton? {
                button.highlighted = false
                
                // TODO: xxx
                
                println("link long pressed")
            }
        }
    }
    
    // MARK: DTAttributedTextContentViewDelegate
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttributedString string: NSAttributedString!, frame: CGRect) -> UIView! {
        let attributes = string.attributesAtIndex(0, effectiveRange: nil) as Dictionary
        
        let identifier = attributes[DTGUIDAttribute] as String?
        
        let button = DTLinkButton(frame: frame)
        
        if let URL = attributes[DTLinkAttribute] as NSURL? {
            button.URL = URL
        }
        button.minimumHitSize = CGSize(width: 25, height: 25)
        button.GUID = identifier ?? ""
        
        // get image with normal link text
        let normalImage = attributedTextContentView.contentImageWithBounds(frame, options: DTCoreTextLayoutFrameDrawingOptions.Default)
        button.setImage(normalImage, forState: UIControlState.Normal)
        
        // get image for highlighted link text
        let highlightImage = attributedTextContentView.contentImageWithBounds(frame, options: DTCoreTextLayoutFrameDrawingOptions.DrawLinksHighlighted)
        button.setImage(highlightImage, forState: UIControlState.Highlighted)
        
        // use normal push action for opening URL
        button.addTarget(self, action: Selector("linkPushed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        // demonstrate combination with long press
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("linkLongPressed:"))
        button.addGestureRecognizer(longPress)
        
        return button
    }
    
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        if attachment is DTImageTextAttachment {
            // if the attachment has a hyperlinkURL then this is currently ignored
            let imageView = UIImageView(frame: frame)
            
            // sets the image if there is one
            imageView.image = (attachment as DTImageTextAttachment).image
            imageView.sd_setImageWithURL(attachment.contentURL, completed: { [unowned self] (image, error, cacheType, imageURL) -> Void in
                let size = image.size
                let maxWidth = attributedTextContentView.frame.size.width
                if size.width > maxWidth {
                    let scale = maxWidth / size.width
                    let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
                    attachment.displaySize = scaledSize
//                    self._imageSizeCache.setObject(NSValue(CGSize: scaledSize), forKey: imageURL)
                } else {
//                    self._imageSizeCache.setObject(NSValue(CGSize: image.size), forKey: imageURL)
                }
                self.reloadCellBlock?();
            })
            
            //            imageView.setImageWithURLRequest(NSURLRequest(URL: attachment.contentURL), placeholderImage: UIImage(named: "time_icon"), success: { (request, response, image) -> Void in
            //
            //                let size = image.size
            //                let maxWidth = attributedTextContentView.frame.size.width
            ////                if size.width > maxWidth {
            ////                    let scale = maxWidth / size.width
            ////                    let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
            ////                    attachment.displaySize = scaledSize
            ////                    self._imageSizeCache.setObject(NSValue(CGSize: scaledSize), forKey: attachment.contentURL )
            ////                } else {
            ////                    self._imageSizeCache.setObject(NSValue(CGSize: image.size), forKey: attachment.contentURL)
            ////                }
            //                self.tableView.reloadData()
            //            }, failure: { (request, response, error) -> Void in
            //
            //            })
            
            // if there is a hyperlink then add a link button on top of this image
            if attachment.hyperLinkURL != nil {
                // NOTE: this is a hack, you probably want to use your own image view and touch handling
                // also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
                imageView.userInteractionEnabled = true
                
                let button = DTLinkButton(frame: imageView.bounds)
                button.URL = attachment.hyperLinkURL
                button.minimumHitSize = CGSizeMake(25, 25) // adjusts it's bounds so that button is always large enough
                button.GUID = attachment.hyperLinkGUID
                
                // use normal push action for opening URL
                button.addTarget(self, action: Selector("linkPushed:"), forControlEvents: UIControlEvents.TouchUpInside)
                
                // demonstrate combination with long press
                let longPress = UILongPressGestureRecognizer(target: self, action: Selector("linkLongPressed:"))
                button.addGestureRecognizer(longPress)
                
                imageView.addSubview(button)
            }
            
            return imageView
        } else if attachment is DTIframeTextAttachment {
            let videoView = DTWebVideoView(frame: frame)
            videoView.attachment = attachment
            
            return videoView
        } else if attachment is DTObjectTextAttachment {
            let someView = UIView(frame: frame)
            
            
            // somecolorparameter has a HTML color
            if let colorName = attachment.attributes["somecolorparameter"] as String? {
                let someColor = DTColorCreateWithHTMLName(colorName)
                someView.backgroundColor = someColor
                someView.accessibilityLabel = colorName
                someView.isAccessibilityElement = true
            }
            
            someView.layer.borderWidth = 1
            someView.layer.borderColor = UIColor.blackColor().CGColor
            
            return someView
        }
        
        
        return UIView(frame: CGRectZero)
    }
}
