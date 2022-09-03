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

class AddNewTaskViewController: UIViewController {
    
    @IBOutlet weak var viewWithButtonsForAddTask: UIView!
    @IBOutlet weak var bottomViewWithButtons: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subTasksTableView: ContentSizedTableView!
    
    @IBOutlet weak var addSubTaskButton: UIButton!
    @IBOutlet weak var changeDateButton: UIButton!
    
    let realm = try! Realm()
    let taskManager = TaskManager()
    var subTasksArray = [SubTask]()
   // var subTaskList = List<SubTask>()
    var selectedDate: Date?
    
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subTasksTableView.register(UINib(nibName: "SubTaskTableViewCell", bundle: nil), forCellReuseIdentifier: "SubTaskReusableCell")
        self.subTasksTableView.dataSource = self
        
        bottomViewWithButtons.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        //titleTextField.becomeFirstResponder()
        
        if task != nil {
            titleTextField.text = task!.title
            let date = task?.date?.formatted(date: .abbreviated, time: .omitted)
            changeDateButton.setTitle(date, for: .normal)
//                .formatted(Date.FormatStyle()
//                .day(.defaultDigits)
//                .month(.wide)
//                .weekday(.wide))
            for subTask in task!.subTasks {
                subTasksArray.append(subTask)
            }
        }
        
    }
    
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
            updateTask()
            try! realm.write {
                realm.add(task!)
            }
        }
        
        self.dismiss(animated: true)
    }
    
    
    func updateTask() {
        let tasks = realm.objects(Task.self)
        let dateType = taskManager.getDateType(for: selectedDate ?? Date())
        task!.title = titleTextField.text ?? "New task"
        task!.rowInSection = tasks.where {$0.dateType == dateType}.count
        task!.date = selectedDate
        task!.dateType = dateType
        for i in 0..<task!.subTasks.count {
            task!.subTasks[i].title = subTasksArray[i].title
        }
        for i in task!.subTasks.count..<subTasksArray.count {
            task!.subTasks.append(subTasksArray[i])
        }
        
    }
    

    @IBAction func unwindSegueToAddNewTaskViewController(segue: UIStoryboardSegue) {
        guard let svc = segue.source as? DatePickerPopupViewController else {return}
        self.selectedDate = svc.datePicker.date
    }

}


extension AddNewTaskViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subTasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = subTasksTableView.dequeueReusableCell(withIdentifier: "SubTaskReusableCell", for: indexPath) as! SubTaskTableViewCell
        
        cell.titleTextField.delegate = self
        cell.titleTextField.tag = indexPath.row
        try! realm.write{
            cell.titleTextField.text = subTasksArray[indexPath.row].title
        }
        return cell
    }
}



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
   
}
