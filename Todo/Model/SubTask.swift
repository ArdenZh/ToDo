//
//  SubTask.swift
//  Todo
//
//  Created by Arden Zhakhin on 15.08.2022.
//

import Foundation
import RealmSwift

class SubTask: EmbeddedObject {
    @Persisted var title: String = ""
    @Persisted var doneProperty: Bool = false
    //@Persisted(originProperty: "subTasks") var parentTask: LinkingObjects<Task>
}
