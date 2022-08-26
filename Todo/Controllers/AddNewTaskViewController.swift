//
//  AddNewTaskViewController.swift
//  Todo
//
//  Created by Arden Zhakhin on 12.08.2022.
//

import UIKit
import RealmSwift
import DatePickerDialog

class AddNewTaskViewController: UIViewController {

    let realm = try! Realm()
    var subTasksArray = [SubTask]()
    let taskManager = TaskDateManager()
    
    @IBOutlet weak var bottomViewWithButtons: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subTasksTableView: ContentSizedTableView!
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subTasksTableView.register(UINib(nibName: "SubTaskTableViewCell", bundle: nil), forCellReuseIdentifier: "SubTaskReusableCell")
        self.subTasksTableView.dataSource = self
        
        bottomViewWithButtons.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        titleTextField.becomeFirstResponder()
    }
    
    
    @IBAction func addSubTaskPressed(_ sender: UIButton) {
        let newSubTask = SubTask()
        subTasksArray.append(newSubTask)
        subTasksTableView.reloadData()
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        let task = Task()
        task.title = titleTextField.text ?? "New task"
        
        if selectedDate != nil {
            task.taskDate = selectedDate!
            task.taskDateType = taskManager.getDateType(for: selectedDate!)
        }

        for subtask in subTasksArray {
            task.subTasks.append(subtask)
        }
        do {
            try realm.write {
                realm.add(task)
            }
        } catch {
            print("Error saving new items, \(error)")
        }
        self.dismiss(animated: true)
    }
    

    @IBAction func unwindSegueToAddNewTaskViewController(segue: UIStoryboardSegue) {
        guard let svc = segue.source as? DatePickerPopupViewController else {return}
        self.selectedDate = svc.datePicker.date
    }

}


extension AddNewTaskViewController: UITableViewDataSource, UITextFieldDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subTasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = subTasksTableView.dequeueReusableCell(withIdentifier: "SubTaskReusableCell", for: indexPath) as! SubTaskTableViewCell
        cell.titleTextField.delegate = self
        cell.titleTextField.text = subTasksArray[indexPath.row].title
        cell.titleTextField.tag = indexPath.row
        return cell
    }
    
    
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
