//
//  ThridPartyNetworking.swift
//  V2EX
//
//  Created by WildCat on 7/27/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
import Alamofire

class ThirdPartyNetworking {
    
    /// Imgur blocked China
    /// The name of file field should be changed to 'Filedata'
    class func upLoadImage2Imgur(#image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        let urlRequest = urlRequestWithComponents("https://imgur.com/upload", parameters: Dictionary(), imageData: imageData)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON \(JSON)")
                println("ERROR \(error)")
        }
    }
    
    class func uploadImage2SinaCustomService(#image: UIImage, progressClosure: ((percentage: Float) -> Void)?, responseClosure: ((error: NSError?, problemMessage: String?, imageURL: String?) -> Void)?) {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        // parameters: ["accessKey": "29c971c7-b833-4150-b93d-1605a238983b"]
        
        let urlRequest = urlRequestWithComponents("http://pic.xiaojianjian.net/webtools/picbed/upload.htm", parameters: Dictionary(), imageData: imageData)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
//                println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                let percentage = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                progressClosure?(percentage: percentage)
            }
            .responseJSON { (request, response, JSON, error) in
//                println("REQUEST \(request)")
//                println("RESPONSE \(response)")
//                println("JSON \(JSON)")
//                println("ERROR \(error)")

                if let responseJSON = JSON as? [String: String] {
                    
                    if let imageURL = responseJSON["original_pic"] {
                        responseClosure?(error: nil, problemMessage: nil, imageURL: imageURL)
                        return
                    } else if let errorMessage = responseJSON["error_msg"] {
                        responseClosure?(error: nil, problemMessage: "上传失败，每个 IP 每天仅允许上传图片 10 张", imageURL: nil)
                        return
                    }
                }
                
                if error != nil {
                    responseClosure?(error: error, problemMessage: nil, imageURL: nil)
                } else {
                    responseClosure?(error: nil, problemMessage: "图片上传失败，未知错误", imageURL: nil)
                }
        }
    }
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    // Ref: http://stackoverflow.com/questions/26121827/uploading-file-with-parameters-using-alamofire
    private class func urlRequestWithComponents(urlString:String, parameters: [String: String], imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/jpeg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
//    private class func contentTypeFromImageData(data: NSData) -> String {
//        var c = UInt8()
//        data.getBytes(&c, length: 1)
//        switch c {
//        case 0xFF:
//            return "image/jpeg"
//        case 0x89:
//            return "image/png"
//        case 0x47:
//            return "image/gif"
//            //        case 0x49:
//            //            break;
//        case 0x42:
//            return "image/bmp"
//        case 0x4D:
//            return "image/tiff"
//        default:
//            return "image/unknown"
//        }
//    }
    
}