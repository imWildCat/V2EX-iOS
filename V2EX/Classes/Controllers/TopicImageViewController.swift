//
//  TopicImageViewController.swift
//  V2EX
//
//  Created by WildCat on 12/7/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import UIKit
import JTSImageViewController

class TopicImageViewController: JTSImageViewController {
    
//    var longPressClosure: ((imageVC: TopicImageViewController) -> Void)!
    
//    convenience init(imageInfo: JTSImageInfo!, mode: JTSImageViewControllerMode, backgroundStyle backgroundOptions: JTSImageViewControllerBackgroundOptions, longPressClosure: (imageVC: TopicImageViewController) -> Void) {
//        self.init(imageInfo: imageInfo, mode: mode, backgroundStyle: backgroundOptions)
//        self.longPressClosure = longPressClosure
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let recognizer = UILongPressGestureRecognizer(target: self, action: "viewDidLongPress:")
        view.addGestureRecognizer(recognizer)
    }
    
    func viewDidLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .Began {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let saveAction = UIAlertAction(title: "保存到相册", style: .Default) { [unowned self] action in
                UIImageWriteToSavedPhotosAlbum(self.image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
            let openInSafariAction = UIAlertAction(title: "在 Safari 中打开", style: .Default) { [unowned self] action -> Void in
                UIApplication.sharedApplication().openURL(self.imageInfo.imageURL)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(saveAction)
            alert.addAction(openInSafariAction)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error != nil {
            showHUDErrorMessage("保存失败，请允许访问相册")
        } else {
            showHUDSuccessMessage("保存成功")
        }
    }

}
