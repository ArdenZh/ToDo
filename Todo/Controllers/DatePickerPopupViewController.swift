//
//  DatePickerPopupViewController.swift
//  Todo
//
//  Created by Arden Zhakhin on 16.08.2022.
//

import UIKit

protocol DatePickerDelegate: UIViewController {
    func updateTaskDate(date: Date)
    func updateNotificationDate(date: Date)
}

enum DatePickerMode {
    case date
    case dateAndTime
}

class DatePickerPopupViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var datePickerMode = DatePickerMode.date
    
    weak var delegate: DatePickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.layer.cornerRadius = CGFloat(10)
        cancelButton.layer.borderWidth = CGFloat(1)
        cancelButton.layer.borderColor = UIColor(named: K.Colors.borderColor)?.cgColor
        saveButton.layer.borderWidth = CGFloat(1)
        saveButton.layer.borderColor = UIColor(named: K.Colors.borderColor)?.cgColor
        datePicker.minimumDate = Date()
        
        switch datePickerMode {
        case .date:
            datePicker.datePickerMode = .date
        case .dateAndTime:
            datePicker.datePickerMode = .dateAndTime
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        switch datePickerMode {
        case .date:
            delegate?.updateTaskDate(date: datePicker.date)
        case .dateAndTime:
            delegate?.updateNotificationDate(date: datePicker.date)
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
