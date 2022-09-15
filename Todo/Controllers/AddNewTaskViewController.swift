//
//  AddNewTaskViewController.swift
//  Todo
//
//  Created by Arden Zhakhin on 12.08.2022.
//

import UIKit
import RealmSwift
import DatePickerDialog
import SwiftUI
import UserNotifications
import AuthenticationServices


class AddNewTaskViewController: UIViewController {
    
    @IBOutlet weak var viewWithButtonsForAddTask: UIView!
    @IBOutlet weak var bottomViewWithButtons: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subTasksTableView: ContentSizedTableView!
    
    @IBOutlet weak var addSubTaskButton: UIButton!
    @IBOutlet weak var changeDateButton: UIButton!
    @IBOutlet weak var addReminderButton: UIButton!
    @IBOutlet weak var changeReminderButton: UIButton!
    
    
    
    let realm = try! Realm()
    let taskManager = TaskManager()
    var subTasksArray = [SubTask]()
    var selectedDate: Date?
    let notificationManager = NotificationManager()
    var selectedNotificationDate: Date?
    
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subTasksTableView.register(UINib(nibName: K.subTaskCellNibName, bundle: nil), forCellReuseIdentifier: K.subTaskCellIdentifier)
        self.subTasksTableView.dataSource = self
        
        bottomViewWithButtons.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        titleTextField.becomeFirstResponder()
        
        
        if task != nil {
            titleTextField.text = task!.title
            
            if let date = task!.date?.formatted(date: .abbreviated, time: .omitted) {
                changeDateButton.setTitle(date, for: .normal)
                changeDateButton.setTitleColor(UIColor(named: K.Colors.blue), for: .normal)
                changeDateButton.setImage(UIImage(named: K.Images.dateSelected), for: .normal)
                selectedDate = task!.date
            }
            
            if let reminder = task!.notificationDate?.formatted(date: .abbreviated, time: .shortened) {
                changeReminderButton.setTitle(reminder, for: .normal)
                changeReminderButton.setTitleColor(UIColor(named: K.Colors.blue), for: .normal)
                changeReminderButton.setImage(UIImage(named: K.Images.notificationSelected), for: .normal)
                selectedNotificationDate = task!.notificationDate
            }
            
            for subTask in task!.subTasks {
                subTasksArray.append(subTask)
            }
        }
        
    }
    
    
    //MARK: - Actions
    @IBAction func addSubTaskPressed(_ sender: UIButton) {
        
        let newSubTask = SubTask()
        newSubTask.row = subTasksArray.count
        subTasksArray.append(newSubTask)
        subTasksTableView.reloadData()
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
    
        if task != nil {
            try! realm.write {
                updateTask()
            }
        } else {
            task = Task()
            addTask()
            try! realm.write {
                realm.add(task!)
            }
        }
        if selectedNotificationDate != nil {
            notificationManager.scheduleNotification(for: task!)
        }
        
        self.dismiss(animated: true)
    }
    
    
    func updateTask() {
        let dateType = taskManager.getDateType(for: selectedDate ?? Date())
        task!.title = titleTextField.text ?? "New task"
        task!.date = selectedDate
        task!.dateType = dateType
        task!.notificationDate = selectedNotificationDate
        for i in 0..<task!.subTasks.count {
            task!.subTasks[i].title = subTasksArray[i].title
        }
        for i in task!.subTasks.count..<subTasksArray.count {
            task!.subTasks.append(subTasksArray[i])
        }
        
    }
    
    func addTask() {
        updateTask()
        let tasks = realm.objects(Task.self)
        let dateType = taskManager.getDateType(for: selectedDate ?? Date())
        task!.rowInSection = tasks.where {$0.dateType == dateType}.count
    }
    
    
    @IBAction func addDatePressed(_ sender: Any) {
        performSegue(withIdentifier: K.Segues.addTaskDateSegue, sender: nil)
    }
    
    
    @IBAction func addNotificationPressed(_ sender: Any) {
        notificationManager.requestAutorization()
//        notificationManager.notificationCenter.delegate = notificationManager
        performSegue(withIdentifier: K.Segues.addNotificationSegue, sender: nil)
    }
    
    
//MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.addTaskDateSegue {
            guard let destinationVC = segue.destination as? DatePickerPopupViewController else {return}
            destinationVC.delegate = self
            if let date = selectedDate {
                destinationVC.datePicker.date = date
            }
        } else if segue.identifier == K.Segues.addNotificationSegue {
            guard let destinationVC = segue.destination as? DatePickerPopupViewController else {return}
            destinationVC.delegate = self
            destinationVC.datePickerMode = .dateAndTime
        }
    }

}

//MARK: - DatePickerDelegate
//When user has selected the date
extension AddNewTaskViewController: DatePickerDelegate {
    func updateTaskDate(date: Date) {
        selectedDate = date
    }
    
    func updateNotificationDate(date: Date) {
        selectedNotificationDate = date
    }
    
}

//MARK: - TableViewDataSourse
extension AddNewTaskViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subTasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = subTasksTableView.dequeueReusableCell(withIdentifier: K.subTaskCellIdentifier, for: indexPath) as! SubTaskTableViewCell
        
        cell.titleTextField.delegate = self
        cell.titleTextField.tag = indexPath.row
        try! realm.write{
            cell.titleTextField.text = subTasksArray[indexPath.row].title
        }
        cell.delegate = self
        return cell
    }
}


//MARK: - TextFieldDelegate
extension AddNewTaskViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textUpdated = textFieldText.replacingCharacters(in: range, with: string) as String
        textField.text! = textUpdated
        
        do {
            try realm.write {
                subTasksArray[textField.tag].title.append(string)
            }
        } catch {
            print("Error saving new items, \(error)")
        }
        
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        subTasksArray.remove(at: textField.tag)
        if task != nil  {
            if task!.subTasks.count >= subTasksArray.count {
                try! realm.write {
                    task?.subTasks.remove(at: textField.tag)
                }
            }
        }
        let position = CGPoint(x: 0, y: textField.tag)
        if let indexPath = subTasksTableView.indexPathForRow(at: position){
            subTasksTableView.deleteRows(at: [indexPath], with: .left)
            subTasksTableView.reloadData()
        }
        return true
    }
}


//MARK: - SubTaskTableViewCellDelegate
extension AddNewTaskViewController: SubTaskTableViewCellDelegate {
    
    func subTaskDoneButtonPressed(onCell cell: SubTaskTableViewCell) {
        
        guard let indexPath = subTasksTableView.indexPath(for: cell) else {return}
        
        subTasksArray.remove(at: indexPath.row)
        
        if task != nil {
            try! realm.write {
                task?.subTasks.remove(at: indexPath.row)
            }
        }
        
        subTasksTableView.deleteRows(at: [indexPath], with: .left)
        subTasksTableView.reloadData()
    }
}
