//
//  NotificationsManager.swift
//  Todo
//
//  Created by Arden Zhakhin on 04.09.2022.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAutorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
        }
    }
    
    func scheduleNotification(for task: Task) {
        
        guard let date = task.notificationDate else {return}
        
        let content = UNMutableNotificationContent()
        let userAction = "User Action"
        
        content.title = "Todo"
        content.body = "Task reminder: " + task.title
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = userAction
        
        let calendar = Calendar(identifier: .gregorian)
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let dateComponents = calendar.dateComponents(components, from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
        let identifire = "Notification for \(task.title)"
        let request = UNNotificationRequest(identifier: identifire,
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
            completionHandler([.banner, .list, .sound])
    }
    
}
