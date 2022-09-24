//
//  AddNewTaskViewController.swift
//  Todo
//
//  Created by Arden Zhakhin on 12.08.2022.
//

import UIKit
import RealmSwift

class AddNewTaskViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subTasksTableView: ContentSizedTableView!
    @IBOutlet weak var bottomViewWithButtons: UIView!
    @IBOutlet weak var addSubTaskButton: UIButton!
    @IBOutlet weak var changeDateButton: UIButton!
    @IBOutlet weak var changeReminderButton: UIButton!
    @IBOutlet weak var changeFavouriteButton: UIButton!
    @IBOutlet weak var deleteTaskButton: UIButton!
    @IBOutlet weak var addDateButton: UIButton!
    @IBOutlet weak var addNotificationButton: UIButton!
    @IBOutlet weak var addFavouriteButton: UIButton!
    
    let realm = try! Realm()
    let taskManager = TaskManager()
    var subTasksArray = [SubTask]()
    var selectedDate: Date?
    let notificationManager = NotificationManager()
    var selectedNotificationDate: Date?
    var selectedFavourite = false
    
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subTasksTableView.register(UINib(nibName: K.subTaskCellNibName, bundle: nil), forCellReuseIdentifier: K.subTaskCellIdentifier)
        self.subTasksTableView.dataSource = self
        
        bottomViewWithButtons.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        titleTextField.becomeFirstResponder()
        
        
        if task != nil {
            titleTextField.text = task!.title
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_us")
            formatter.dateStyle = .medium
            
            if let date = task!.date {
                formatter.timeStyle = .none
                let dateStr = formatter.string(from: date)
                changeDateButton.setTitle(dateStr, for: .normal)
                changeDateButton.setTitleColor(UIColor(named: K.Colors.blue), for: .normal)
                changeDateButton.setImage(UIImage(named: K.Images.dateSelected), for: .normal)
                selectedDate = task!.date
            }
            
            if let reminder = task!.notificationDate {
                formatter.timeStyle = .short
                let dateStr = formatter.string(from: reminder)
                changeReminderButton.setTitle(dateStr, for: .normal)
                changeReminderButton.setTitleColor(UIColor(named: K.Colors.blue), for: .normal)
                changeReminderButton.setImage(UIImage(named: K.Images.notificationSelected), for: .normal)
                selectedNotificationDate = task!.notificationDate
            }
            
            selectedFavourite = task!.isFavourite
            if task!.isFavourite {
                addFavouriteButton.setImage(UIImage(named: K.Images.favouritesSelected), for: .normal)
                changeFavouriteButton.setImage(UIImage(named: K.Images.favouritesSelected), for: .normal)
                changeFavouriteButton.setTitleColor(UIColor(named: K.Colors.blue), for: .normal)
                changeFavouriteButton.setTitle("Remove from favourites", for: .normal)
            }
            
            bottomViewWithButtons.isHidden = true
            
            for subTask in task!.subTasks {
                subTasksArray.append(subTask)
            }
        } else {
            changeDateButton.isHidden = true
            changeReminderButton.isHidden = true
            changeFavouriteButton.isHidden = true
            deleteTaskButton.isHidden = true
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
        task!.isFavourite = selectedFavourite
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
    
    
    
    @IBAction func changeFavouritePressed(_ sender: UIButton) {
        selectedFavourite = !selectedFavourite
        if selectedFavourite {
            addFavouriteButton.setImage(UIImage(named: K.Images.favouritesSelected), for: .normal)
            changeFavouriteButton.setImage(UIImage(named: K.Images.favouritesSelected), for: .normal)
            changeFavouriteButton.setTitleColor(UIColor(named: K.Colors.blue), for: .normal)
            changeFavouriteButton.setTitle("Remove from favourites", for: .normal)
        } else {
            addFavouriteButton.setImage(UIImage(named: K.Images.favourites), for: .normal)
            changeFavouriteButton.setImage(UIImage(named: K.Images.favourites), for: .normal)
            changeFavouriteButton.setTitleColor(UIColor(named: K.Colors.contentDark), for: .normal)
            changeFavouriteButton.setTitle("Add to favourites", for: .normal)
        }
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
        addDateButton.setImage(UIImage(named: K.Images.dateSelected), for: .normal)
        changeDateButton.setImage(UIImage(named: K.Images.dateSelected), for: .normal)
        changeDateButton.setTitleColor(UIColor(named: K.Colors.blue), for: .normal)
    }
    
    func updateNotificationDate(date: Date) {
        selectedNotificationDate = date
        addNotificationButton.setImage(UIImage(named: K.Images.notificationSelected), for: .normal)
        changeReminderButton.setImage(UIImage(named: K.Images.notificationSelected), for: .normal)
        changeReminderButton.setTitleColor(UIColor(named: K.Colors.blue), for: .normal)
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
