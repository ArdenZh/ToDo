//
//  DateManager.swift
//  Todo
//
//  Created by Arden Zhakhin on 21.08.2022.
//

import Foundation
import RealmSwift

class TaskManager {
    
    let realm = try! Realm()
    
    //MARK: - Manage task date types
    
    func updateAllTasksDateTypes() {
        
        let allTasks = realm.objects(Task.self)
        for task in allTasks {
            try! realm.write {
                task.dateType = getDateType(for: task.date)
            }
        }
    }
    
    func getDateType(for date: Date?) -> TaskDateType {
        let calendar = Calendar(identifier: .gregorian)
        
        guard let date = date else {return .today}
        
        if calendar.isDateInToday(date) || date < Date() {
            return .today
        } else if calendar.isDateInTomorrow(date) {
            return .tomorrow
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            return .onTheWeek
        } else {
            return .someday
        }
    }
    
    
    //MARK: - "Move" task
    
    func replaceTask(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        //var task : Task?
        
        print("sourceIndexPath.section: \(sourceIndexPath.section)")
        print("destinationIndexPath.section: \(destinationIndexPath.section)")
        print(sourceIndexPath.row)
        
        var task = getTasksFromSelectedSection(at: sourceIndexPath).where {
            $0.rowInSection == sourceIndexPath.row
        }
        
        print(task)
        print(task.first?.title)
        
        guard let t = task.first else {return}
        
        decreaseAllTasksRows(after: sourceIndexPath)
        increaseAllTasksRows(after: destinationIndexPath)
        updateTaskDateWhenMoving(t, from: sourceIndexPath, to: destinationIndexPath)
        
        try! realm.write {
            t.rowInSection = destinationIndexPath.row
        }
    }
    
    
    func updateTaskDateWhenMoving(_ task: Task, from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
       
        guard sourceIndexPath.section != destinationIndexPath.section else {return}
        
        let calendar = Calendar(identifier: .gregorian)
        
        try! realm.write {
            switch destinationIndexPath.section {
            case 0:
                task.dateType = .today
                task.date = Date()
            case 1:
                task.dateType = .tomorrow
                task.date = calendar.date(byAdding: .day, value: 1, to: Date())
            case 2:
                task.dateType = .onTheWeek
                task.date = calendar.date(byAdding: .day, value: 2, to: Date())
            case 3:
                task.dateType = .someday
                task.date = nil
            default: return
            }
        }
    }
    
    
    //MARK: - Increase/Decrease tasks row
    
    func decreaseAllTasksRows(after indexPath: IndexPath) {
        
        var tasksForUpdate: Results<Task>
        
        tasksForUpdate = getTasksFromSelectedSection(at: indexPath).where {
            $0.rowInSection > indexPath.row
        }
        
        try! realm.write{
            for task in tasksForUpdate {
                task.rowInSection -= 1
            }
        }
    }
    
    func increaseAllTasksRows(after indexPath: IndexPath) {
        
        var tasksForUpdate: Results<Task>
        
        tasksForUpdate = getTasksFromSelectedSection(at: indexPath).where {
            $0.rowInSection >= indexPath.row
        }
        try! realm.write{
            for task in tasksForUpdate {
                task.rowInSection += 1
            }
        }
    }
    
    
    //MARK: - Task selection
    
    func getTodayTasks() -> Results<Task>{
        let tasks = realm.objects(Task.self)
            .where {$0.dateType == .today}
            .sorted (byKeyPath: "rowInSection")
        return tasks
    }
    
    func getTomorrowTasks() -> Results<Task>{
        let tasks = realm.objects(Task.self)
            .where {$0.dateType == .tomorrow}
            .sorted (byKeyPath: "rowInSection")
        return tasks
    }
    
    func getOnTheWeekTasks() -> Results<Task>{
        let tasks = realm.objects(Task.self)
            .where {$0.dateType == .onTheWeek}
            .sorted (byKeyPath: "rowInSection")
        return tasks
    }
    
    func getSomedayTasks() -> Results<Task>{
        let tasks = realm.objects(Task.self)
            .where {$0.dateType == .someday}
            .sorted (byKeyPath: "rowInSection")
        return tasks
    }
    
    func getTasksFromSelectedSection(at indexPath: IndexPath) -> Results<Task>{
        
        switch indexPath.section {
        case 0:
            return getTodayTasks()
        case 1:
            return getTomorrowTasks()
        case 2:
            return getOnTheWeekTasks()
        case 3:
            return getSomedayTasks()
        default:
            return getTodayTasks()
        }
    }
    
    func getTaskByDateTypeAndRow(dateTypeString: String, row: Int) -> Task? {
        let task = realm.objects(Task.self)
            .where {$0.dateType.rawValue == dateTypeString && $0.rowInSection == row}
        return task.first
    }

}












