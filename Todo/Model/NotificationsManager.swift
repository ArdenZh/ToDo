//
//  NotificationsManager.swift
//  Todo
//
//  Created by Arden Zhakhin on 04.09.2022.
//

import Foundation
import UserNotifications
import RealmSwift

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    let taskManager = TaskManager()
    let realm = try! Realm()
    
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
        let userAction = "Task reminder"
        
        content.title = "Todo"
        content.body = "Task reminder: " + task.title
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = userAction
        
        let calendar = Calendar(identifier: .gregorian)
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let dateComponents = calendar.dateComponents(components, from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let identifire = "\(task.dateType.rawValue) \(task.rowInSection)"
        let request = UNNotificationRequest(identifier: identifire,
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let action1 = UNNotificationAction(identifier: "action1", title: "Remind in 15 minutes", options: [])
        let action2 = UNNotificationAction(identifier: "action2", title: "Remind me after 30 minutes", options: [])
        let action3 = UNNotificationAction(identifier: "action3", title: "Remind me after one hour", options: [])
        let action4 = UNNotificationAction(identifier: "action4", title: "Remind me tomorrow", options: [])
        let category = UNNotificationCategory(
            identifier: userAction,
            actions: [action1, action2, action3, action4],
            intentIdentifiers: [],
            options: [])
        
        notificationCenter.setNotificationCategories([category])
        
        
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
            completionHandler([.banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let components = response.notification.request.identifier.components(separatedBy: " ")
        let taskDateType = components.first!
        let taskRowInSection = components.last!
        
        guard let task = taskManager.getTaskByDateTypeAndRow(dateTypeString: taskDateType, row: Int(taskRowInSection)!) else {return}
        
        switch response.actionIdentifier{
        case UNNotificationDismissActionIdentifier:
            try! realm.write{
                task.notificationDate = nil
            }
        case UNNotificationDefaultActionIdentifier:
            try! realm.write{
                task.notificationDate = nil
            }
        case "action1":
            try! realm.write{
                task.notificationDate?.addTimeInterval(15 * 60)
            }
            scheduleNotification(for: task)
        case "action2":
            try! realm.write{
                task.notificationDate?.addTimeInterval(30 * 60)
            }
            scheduleNotification(for: task)
        case "action3":
            try! realm.write{
                task.notificationDate?.addTimeInterval(60 * 60)
            }
            scheduleNotification(for: task)
        case "action4":
            try! realm.write{
                task.notificationDate?.addTimeInterval(24 * 60 * 60)
            }
            scheduleNotification(for: task)
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}
