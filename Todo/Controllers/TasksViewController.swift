//
//  ViewController.swift
//  Todo
//
//  Created by Arden Zhakhin on 08.08.2022.
//

import UIKit
import RealmSwift
import InstantSearchVoiceOverlay

class TasksViewController: UIViewController {
    
    @IBOutlet weak var tasksTableView: ContentSizedTableView!
    @IBOutlet weak var addNewTaskButton: UIButton!
    
    let realm = try! Realm()
    var notificationToken: NotificationToken?
    
    let taskManager = TaskManager()
    
    lazy var voiceOverlayController: VoiceOverlayController = {
      let recordableHandler = {
        return SpeechController(locale: Locale(identifier: "en_US"))
      }
      return VoiceOverlayController(speechControllerHandler: recordableHandler)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksTableView.register(UINib(nibName: K.taskCellNibName, bundle: nil), forCellReuseIdentifier: K.taskCellIdentifier)
        tasksTableView.dataSource = self
        tasksTableView.delegate = self
        tasksTableView.dragDelegate = self
        tasksTableView.dragInteractionEnabled = true

        
        //update table view when new task is added
        let allTasks = realm.objects(Task.self)
        addRealmObserver(results: allTasks)
        
        // Update tasks date when app loaded up
        taskManager.updateAllTasksDateTypes()
        
        // Update tasks date when a new day comes and the app is active
        NotificationCenter.default.addObserver(self, selector: #selector(dayChanged), name: .NSCalendarDayChanged, object: nil)
        
        //add longpress gesture to add button for voice input
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(gesture:)))
        longPress.minimumPressDuration = 0.5
        addNewTaskButton.addGestureRecognizer(longPress)
        setupVoicevoiceOverlayControllerSettings()
    }
    
    func addRealmObserver(results: Results<Task>){
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self?.tasksTableView.reloadData()
            case .update(_, _, _, _):
                self?.tasksTableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    @objc func dayChanged(_ notification: Notification) {
        taskManager.updateAllTasksDateTypes()
        tasksTableView.reloadData()
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            voiceOverlayController.start(on: self, textHandler: { text, final, _ in
                if final {
                    try! self.realm.write{
                        let task = Task()
                        task.title = text
                        task.rowInSection = self.tasksTableView.numberOfRows(inSection: 0)
                        self.realm.add(task)
                        self.tasksTableView.reloadData()
                    }
                }
            }, errorHandler: { (error) in
                print("voice output: error \(String(describing: error))")
            })
          }
    }
    
    func setupVoicevoiceOverlayControllerSettings() {
        voiceOverlayController.settings.layout.inputScreen.titleListening = "Start speaking to add a new task"
        voiceOverlayController.settings.layout.inputScreen.subtitleBulletList = ["Buy eggs", "Send the quarterly report to the boss", "Go for a morning jog"]
        voiceOverlayController.settings.layout.inputScreen.titleInProgress = "Stop speaking to save a new task"
        voiceOverlayController.settings.layout.inputScreen.backgroundColor = UIColor(named: K.Colors.contentDark) ?? UIColor.systemGray
        voiceOverlayController.settings.layout.noPermissionScreen.backgroundColor = UIColor(named: K.Colors.contentDark) ?? UIColor.systemGray
        voiceOverlayController.settings.layout.noPermissionScreen.startGradientColor = UIColor(named: K.Colors.red) ?? UIColor.systemRed
        voiceOverlayController.settings.layout.noPermissionScreen.endGradientColor = UIColor(named: K.Colors.red) ?? UIColor.systemRed
        voiceOverlayController.settings.layout.permissionScreen.backgroundColor = UIColor(named: K.Colors.contentDark) ?? UIColor.systemGray
        voiceOverlayController.settings.layout.permissionScreen.endGradientColor = UIColor(named: K.Colors.blue) ?? UIColor.systemBlue
        voiceOverlayController.settings.showResultScreen = false
    }
    

    
    //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == K.Segues.editTaskSegue {
            if let destinationVC = segue.destination as? AddNewTaskViewController {
                
                guard let taskIndex = tasksTableView.indexPathForSelectedRow  else {return}
                let tasks = taskManager.getTasksFromSelectedSection(at: taskIndex)
                destinationVC.task = tasks[taskIndex.row]
            }
        }
    }

}
 

//MARK: - tableViewDataSource

extension TasksViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return taskManager.getTodayTasks().count
        } else if section == 1 {
            return taskManager.getTomorrowTasks().count
        } else if section == 2 {
            return taskManager.getOnTheWeekTasks().count
        } else if section == 3 {
            return taskManager.getSomedayTasks().count
        } else {
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tasksTableView.dequeueReusableCell(withIdentifier: K.taskCellIdentifier, for: indexPath) as! TaskTableViewCell
        
        let tasks = taskManager.getTasksFromSelectedSection(at: indexPath)
        
        cell.taskTitle.text = tasks[indexPath.row].title
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        taskManager.replaceTask(from: sourceIndexPath, to: destinationIndexPath)
    }
}


//MARK: - tableViewDelegate

extension TasksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segues.editTaskSegue, sender: tableView.cellForRow(at: indexPath))
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        label.textColor = UIColor(named: K.Colors.contentDark)
        label.font = UIFont(name: "Poppins-Medium", size: CGFloat(24))
    
        switch section {
        case 0: label.text = "Today"
        case 1: label.text = "Tomorrow"
        case 2: label.text =  "On the week"
        case 3: label.text =  "Someday"
        default: label.text =  ""
        }
        return label
    }
    
}





//MARK: - Delete task when done button pressed

extension TasksViewController: TaskTableViewCellDelegate {
    
    func taskDoneButtonPressed(onCell cell: TaskTableViewCell) {

        guard let indexPath = tasksTableView.indexPath(for: cell) else {return}
        
        let tasks = taskManager.getTasksFromSelectedSection(at: indexPath)
        taskManager.decreaseAllTasksRows(after: indexPath)
        
        try! realm.write {
            realm.delete(tasks[indexPath.row])
        }

        tasksTableView.deleteRows(at: [indexPath], with: .left)
        tasksTableView.reloadData()
    }
}


extension TasksViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let tasks = taskManager.getTasksFromSelectedSection(at: indexPath)
        
        let item = UIDragItem(itemProvider: NSItemProvider())
        item.localObject = tasks[indexPath.row]
        return [item]
    }
    
    
}
