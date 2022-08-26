//
//  TaskTableViewCell.swift
//  Todo
//
//  Created by Arden Zhakhin on 10.08.2022.
//

import UIKit

protocol TaskTableViewCellDelegate {
    func taskDoneButtonPressed(onCell cell: TaskTableViewCell, from parentTableView: UITableView)
}


class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDoneButton: UIButton!
    
    var delegate: TaskTableViewCellDelegate?
    var parentTableView: ContentSizedTableView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    @IBAction func taskDoneButtonPressed(_ sender: UIButton) {
        taskDoneButton.imageView?.image = UIImage(named: "taskNotDone")
        delegate?.taskDoneButtonPressed(onCell: self, from: parentTableView!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

