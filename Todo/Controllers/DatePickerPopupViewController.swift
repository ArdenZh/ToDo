//
//  DatePickerPopupViewController.swift
//  Todo
//
//  Created by Arden Zhakhin on 16.08.2022.
//

import UIKit

class DatePickerPopupViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.layer.cornerRadius = CGFloat(10)
        cancelButton.layer.borderWidth = CGFloat(1)
        cancelButton.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        saveButton.layer.borderWidth = CGFloat(1)
        saveButton.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        datePicker.minimumDate = Date()
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
