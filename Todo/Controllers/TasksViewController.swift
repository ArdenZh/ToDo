//
//  ViewController.swift
//  Todo
//
//  Created by Arden Zhakhin on 08.08.2022.
//

import UIKit
import RealmSwift

class TasksViewController: UIViewController {
    
    @IBOutlet weak var todayTableView: ContentSizedTableView!
    @IBOutlet weak var tomorrowTableView: ContentSizedTableView!
    @IBOutlet weak var onWeekTableView: ContentSizedTableView!
    @IBOutlet weak var somedayTableView: ContentSizedTableView!
    
    let realm = try! Realm()
    var notificationToken: NotificationToken?
    let taskManager = TaskDateManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todayTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskReusableCell")
        tomorrowTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskReusableCell")
        onWeekTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskReusableCell")
        somedayTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskReusableCell")
        
        self.todayTableView.dataSource = self
        self.tomorrowTableView.dataSource = self
        self.onWeekTableView.dataSource = self
        self.somedayTableView.dataSource = self
        
        let allTasks = realm.objects(Task.self)
        addRealmObserver(results: allTasks)
        
        taskManager.updateAllTasksDateTypes()
        
        //update tasks date when a new day comes and the app is active
        NotificationCenter.default.addObserver(self, selector: #selector(dayChanged), name: .NSCalendarDayChanged, object: nil)
    }
    
    @objc func dayChanged(_ notification: Notification) {
        taskManager.updateAllTasksDateTypes()
        updateTableViews()
    }
    
    
    func updateTableViews(){
        todayTableView.reloadData()
        tomorrowTableView.reloadData()
        onWeekTableView.reloadData()
        somedayTableView.reloadData()
    }
    
    func addRealmObserver(results: Results<Task>){
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self?.updateTableViews()
            case .update(_, _, _, _):
                self?.updateTableViews()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
}
 

//MARK: - tableViewDataSource

extension TasksViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let tasks = realm.objects(Task.self)
        
        if tableView == todayTableView{
            let todayTasks = tasks.where {$0.taskDateType == .today}
            return todayTasks.count
        } else if tableView == tomorrowTableView {
            let tomorrowTasks = tasks.where {$0.taskDateType == .tomorrow}
            return tomorrowTasks.count
        } else if tableView == onWeekTableView {
            let onWeekTasks = tasks.where {$0.taskDateType == .onTheWeek}
            return onWeekTasks.count
        } else if tableView == somedayTableView {
            let somedayTasks = tasks.where {$0.taskDateType == .someday}
            return somedayTasks.count
        } else {
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = todayTableView.dequeueReusableCell(withIdentifier: "TaskReusableCell", for: indexPath) as! TaskTableViewCell
        
       let tasks = realm.objects(Task.self)
        
        if tableView == todayTableView {
            let todayTasks = tasks.where {$0.taskDateType == .today}
            cell.taskTitle.text = todayTasks[indexPath.row].title
            cell.parentTableView = todayTableView
            
        } else if tableView == tomorrowTableView {
            let tomorrowTasks = tasks.where {$0.taskDateType == .tomorrow}
            cell.taskTitle.text = tomorrowTasks[indexPath.row].title
            cell.parentTableView = tomorrowTableView
            
        } else if tableView == onWeekTableView {
            let onWeekTasks = tasks.where {$0.taskDateType == .onTheWeek}
            cell.taskTitle.text = onWeekTasks[indexPath.row].title
            cell.parentTableView = onWeekTableView
            
        } else if tableView == somedayTableView {
            let somedayTasks = tasks.where {$0.taskDateType == .someday}
            cell.taskTitle.text = somedayTasks[indexPath.row].title
            cell.parentTableView = somedayTableView
        }
        cell.tag = indexPath.row
        cell.delegate = self
        return cell
    }
}

extension TasksViewController: TaskTableViewCellDelegate {
    
    func taskDoneButtonPressed(onCell cell: TaskTableViewCell, from parentTableView: UITableView) {
        
        var tasks: Results<Task>
        
        switch parentTableView {
        case todayTableView:
            tasks = realm.objects(Task.self).where {
                $0.taskDateType == .today
            }
        case tomorrowTableView:
            tasks = realm.objects(Task.self).where {
                $0.taskDateType == .tomorrow
            }
        case onWeekTableView:
            tasks = realm.objects(Task.self).where {
                $0.taskDateType == .onTheWeek
            }
        case somedayTableView:
            tasks = realm.objects(Task.self).where {
                $0.taskDateType == .someday
            }
        default: return
        }
        
        try! realm.write {
            realm.delete(tasks[cell.tag])
        }
        
//        if let indexPath = parentTableView.indexPath(for: cell) {
//            parentTableView.deleteRows(at: [indexPath], with: .left)
//        }
        //updateTableViews()
        
    }

}



