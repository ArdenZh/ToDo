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
   // @Persisted var note: String?
    @Persisted var doneProperty: Bool = false
   // @Persisted var section: Int = 0
    @Persisted var rowInSection: Int = 0
    
    @Persisted var date: Date? = nil
    @Persisted var dateType: TaskDateType = .today
    @Persisted var subTasks: List<SubTask>
}

enum TaskDateType: String, PersistableEnum {
    case today
    case tomorrow
    case onTheWeek
    case someday
}



