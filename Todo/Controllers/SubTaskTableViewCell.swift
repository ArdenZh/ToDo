//
//  SubTaskTableViewCell.swift
//  Todo
//
//  Created by Arden Zhakhin on 15.08.2022.
//

import UIKit

protocol SubTaskTableViewCellDelegate {
    func subTaskDoneButtonPressed(onCell cell: SubTaskTableViewCell)
}

class SubTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subTaskDoneButton: UIButton!
    
    var delegate: SubTaskTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func subTaskDoneButtonPressed(_ sender: UIButton) {
        subTaskDoneButton.imageView?.image = UIImage(named: K.Images.taskDone)
        delegate?.subTaskDoneButtonPressed(onCell: self)
    }
    
    
}
