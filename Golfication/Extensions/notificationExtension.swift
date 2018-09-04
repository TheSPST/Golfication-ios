//
//  notificationExtension.swift
//  Golfication
//
//  Created by Khelfie on 04/01/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import UserNotifications
extension UNNotificationAttachment {
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
            try data.write(to: fileURL!, options: [])
            let imageAttachment = try UNNotificationAttachment(identifier: imageFileIdentifier, url: fileURL!, options: options)
            return imageAttachment
        } catch let error {
            debugPrint("error \(error)")
        }
        
        return nil
    }
}
//extension UNNotificationServiceExtension{
//
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//
//        print("bestAttemptContent: \(bestAttemptContent)")
//        print("request.content.userInfo: \(request.content.userInfo)")
//        if let bestAttemptContent = bestAttemptContent {
//            // Modify the notification content here...
//            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//
//            var urlString:String? = nil
//            if let userInfo = request.content.userInfo as NSDictionary as? [String: Any], let imageURL = userInfo["imageURL"] as? String {
//                urlString = imageURL
//            }
//
//            if urlString != nil, let fileUrl = URL(string: urlString!) {
//                print("fileUrl: \(fileUrl)")
//
//                guard let imageData = NSData(contentsOf: fileUrl) else {
//                    contentHandler(bestAttemptContent)
//                    return
//                }
//                guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "image.jpg", data: imageData, options: nil) else {
//                    print("error in UNNotificationAttachment.create()")
//                    contentHandler(bestAttemptContent)
//                    return
//                }
//
//                bestAttemptContent.attachments = [ attachment ]
//            }
//
//            contentHandler(bestAttemptContent)
//        }
//    }
//
//}

