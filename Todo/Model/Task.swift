//
//  Task.swift
//  Todo
//
//  Created by Arden Zhakhin on 11.08.2022.
//

import Foundation
import RealmSwift

class Task: Object {
    @Persisted var title: String = "New task"
    @Persisted var doneProperty: Bool = false
    @Persisted var rowInSection: Int = 0
    @Persisted var date: Date? = nil
    @Persisted var dateType: TaskDateType = .today
    @Persisted var isFavourite: Bool = false
    @Persisted var notificationDate: Date? = nil
    @Persisted var subTasks: List<SubTask>
}

enum TaskDateType: String, PersistableEnum {
    case today
    case tomorrow
    case onTheWeek
    case someday
}



