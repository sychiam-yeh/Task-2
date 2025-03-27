//
//  NewTaskCollectionViewCell.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-26.
//

import UIKit
import SwiftDate

class NewTaskCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "newTaskCell"
    
    fileprivate var datePicker: UIDatePicker?
    var onTextFieldHandler: ((Int, String) -> Void)?
    var addNewTaskVC = AddNewTaskViewController()
    
    /* =================================================================
     *                   MARK: - Outlet Initialization
     * ================================================================== */
    @IBOutlet weak var textField: UITextField!
  
    /* =================================================================
     *                   MARK: - Class Function
     * ================================================================== */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
    }
 
    func configure(value: TaskField, action: ActionType, task: TaskDO) {
        switch action {
        case .update:
            if value == TaskField.taskName {
                self.textField.text = task.title
                self.addNewTaskVC.taskObject.title = task.title
            }
            else if value == TaskField.descName {
                self.textField.text = task.titleDescription
                self.addNewTaskVC.taskObject.titleDescription = task.titleDescription
            }
        case .add:
            self.textField.placeholder = value.stringValue
        }
    }
}

extension NewTaskCollectionViewCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            switch textField.tag {
            case 0:
                self.addNewTaskVC.taskObject.title = text
            case 1:
                self.addNewTaskVC.taskObject.titleDescription = text
            default:
                break
            }
        }
    }
}
