//
//  constants.swift
//  Todo
//
//  Created by Arden Zhakhin on 10.09.2022.
//

import Foundation

struct K {
    
    static let taskCellIdentifier = "TaskReusableCell"
    static let taskCellNibName = "TaskTableViewCell"
    static let subTaskCellIdentifier = "SubTaskReusableCell"
    static let subTaskCellNibName = "SubTaskTableViewCell"
    
    struct Colors {
        static let blue = "blue"
        static let backgroundWhite = "backgroundWhite"
        static let borderColor = "borderColor"
        static let contentDark = "contentDark"
        static let lightBlue = "lightBlue"
        static let red = "red"
        static let yellow = "yellow"
    }
    
    struct Segues {
        static let editTaskSegue = "editTask"
        static let addNewTaskSegue = "addNewTask"
        static let addTaskDateSegue = "addTaskDate"
        static let addNotificationSegue = "addNotification"
        static let addLocationSegue = "addLocation"
    }
    
    struct Images {
        static let date = "date"
        static let dateSelected = "dateSelected"
        static let favourites = "favourites"
        static let favouritesSelected = "favouritesSelected"
        static let location = "location"
        static let locationSelected = "locationSelected"
        static let notification = "notification"
        static let notificationSelected = "notificationSelected"
        static let repeatIcon = "repeat"
        static let repeatSelected = "repeatSelected"
        static let taskDone = "taskDone"
        static let taskNotDone = "taskNotDone"
        static let favouriteFilled = "favouriteFilled"
    }
}
