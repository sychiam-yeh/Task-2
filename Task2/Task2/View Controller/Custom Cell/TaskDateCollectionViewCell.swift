//
//  TaskDateCollectionViewCell.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-27.
//

import UIKit
import IQKeyboardManagerSwift

class TaskDateCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "taskDateCell"
    
    /* =================================================================
     *                   MARK: - Local Initialization
     * ================================================================== */
    fileprivate var datePicker: UIDatePicker?
    fileprivate var timePicker: UIDatePicker?
    var addNewTaskVC = AddNewTaskViewController()
    
    /* =================================================================
     *                   MARK: - Outlet Initialization
     * ================================================================== */
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var duedateLabel: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    
    @IBAction func isSetReminder(_ sender: UISwitch) {
        if sender.isOn {
            self.timeTextField.isHidden = false
        }
        else {
            self.timeTextField.isHidden = true
        }
        self.addNewTaskVC.taskObject.isReminder = sender.isOn
    }
    
    /* =================================================================
     *                   MARK: - Class Function
     * ================================================================== */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.timeTextField.isHidden = true
        
    }
    
    func configure(task: TaskDO, action: ActionType) {
        self.setupDatePicker()
        self.setupTimePicker()
        
        switch action {
        case .update:
            self.duedateLabel.text = task.deadlineDate
            self.timeTextField.text = task.deadlineTime
            self.addNewTaskVC.taskObject.deadlineTime = task.deadlineTime
            self.addNewTaskVC.taskObject.deadlineDate = task.deadlineDate
            
            if task.isReminder {
                self.addNewTaskVC.taskObject.isReminder = task.isReminder
                self.switchButton.isOn = task.isReminder
                self.timeTextField.isHidden = false
            }
        case .add:
            self.timeTextField.placeholder = "Due time"
            self.duedateLabel.placeholder = "Due date"
        }
    }
}

/* =================================================================
 *                   MARK: - Setup UIDatePicker
 * ================================================================== */
extension TaskDateCollectionViewCell {
    fileprivate func setupDatePicker() {
        self.datePicker = UIDatePicker()
        self.datePicker?.datePickerMode = .dateAndTime
        self.datePicker?.minimumDate = Date()
        self.datePicker?.preferredDatePickerStyle = .inline
        self.datePicker?.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        self.duedateLabel.inputView = self.datePicker
        self.duedateLabel.inputAccessoryView = toolbar
    }
    
    fileprivate func setupTimePicker() {
        self.datePicker = UIDatePicker()
        self.datePicker?.datePickerMode = .time
        self.datePicker?.preferredDatePickerStyle = .wheels
        self.datePicker?.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        self.timeTextField.inputView = self.datePicker
        self.timeTextField.inputAccessoryView = toolbar
    }
    
    @objc private func timeChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        self.timeTextField.text = dateFormatter.string(from: sender.date)
        self.addNewTaskVC.taskObject.deadlineTime = dateFormatter.string(from: sender.date)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.duedateLabel.text = dateFormatter.string(from: sender.date)
        self.addNewTaskVC.taskObject.deadlineDate = dateFormatter.string(from: sender.date)
    }
    
    @objc private func donePressed() {
        self.duedateLabel.resignFirstResponder()
        self.timeTextField.resignFirstResponder()
    }
}
