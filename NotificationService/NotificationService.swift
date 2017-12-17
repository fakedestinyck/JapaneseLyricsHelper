//
//  NotificationService.swift
//  NotificationService
//
//  Created by  on Dec/16/2017.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            
            print("----将APNs信息交由个推处理----");
            
            GeTuiExtSdk.handelNotificationServiceRequest(request, withAttachmentsComplete: { (attachments:Array?, errors:Array?) in
                
                //TODO:用户可以在这里处理通知样式的修改，eg:修改标题
                //bestAttemptContent.title = "\(bestAttemptContent.title)"
                
                bestAttemptContent.attachments = attachments as! [UNNotificationAttachment] // 设置通知中的多媒体附件
                print("处理个推APNs展示遇到错误:\(String(describing: errors))")
                self.contentHandler!(bestAttemptContent)
            })
            
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        
        //销毁SDK，释放资源
        GeTuiExtSdk.destory();
        
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
