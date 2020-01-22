//
//  AppDelegate.swift
//  MagicHour1
//
//  Created by higuchiryunosuke on 2020/01/10.
//  Copyright © 2020 higuchiryunosuke. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) {(granted, error) in
                if granted {
                    print("許可する")
                } else {
                    print("許可しない")
                }
            }
            setLocalNotification(title:"今日は納豆の日です", message:"oh! natto!で納豆を混ぜてみませんか？",month: 1, day: 22)
            return true
        }

    private func setLocalNotification(title:String = "", message:String, month: Int, day: Int,hour:Int = 22, minute:Int = 4, second:Int = 0 ){
            // タイトル、本文、サウンド設定の保持
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            content.sound = UNNotificationSound.default
            
            var notificationTime = DateComponents()
            notificationTime.month = month
            notificationTime.day = day
            notificationTime.hour = hour
            notificationTime.minute = minute
            notificationTime.second = second
            
            let trigger: UNNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: false)
            
            // 識別子とともに通知の表示内容とトリガーをrequestに内包
            let request = UNNotificationRequest(identifier: "Natto", content: content, trigger: trigger)
            
            // UNUserNotificationCenterにrequestを加える
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.add(request) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }


}

extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // アプリ起動中でもアラートと音で通知
        completionHandler([.alert, .sound])
    }
}
