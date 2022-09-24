//
//  TaskTableViewCell.swift
//  Todo
//
//  Created by Arden Zhakhin on 10.08.2022.
//

import UIKit

protocol TaskTableViewCellDelegate {
    func taskDoneButtonPressed(onCell cell: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDoneButton: UIButton!
    @IBOutlet weak var favouriteImageView: UIImageView!
    
    var delegate: TaskTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favouriteImageView.isHidden = true
    }
    
    @IBAction func taskDoneButtonPressed(_ sender: UIButton) {
        taskDoneButton.imageView?.image = UIImage(named: K.Images.taskDone)
        delegate?.taskDoneButtonPressed(onCell: self)
        
    }
}

