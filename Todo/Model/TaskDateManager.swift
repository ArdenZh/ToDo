//
//  DateManager.swift
//  Todo
//
//  Created by Arden Zhakhin on 21.08.2022.
//

import Foundation
import RealmSwift

class TaskDateManager {
    
    let realm = try! Realm()
    
    
    func updateAllTasksDateTypes() {
        
        let allTasks = realm.objects(Task.self)
        for task in allTasks {
            try! realm.write {
                task.taskDateType = getDateType(for: task.taskDate)
            }
        }
    }
    
    func getDateType(for date: Date) -> TaskDateType {
        let calendar = Calendar(identifier: .gregorian)
        
        if calendar.isDateInToday(date) || date < Date() {
            return .today
        } else if calendar.isDateInTomorrow(date) {
            return .tomorrow
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfMonth) {
            return .onTheWeek
        } else {
            return .someday
        }
    }
    
}












