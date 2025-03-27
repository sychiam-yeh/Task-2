//
//  CustomCollectionViewCell.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-26.
//


import UIKit
import IBAnimatable

class CustomCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CustomCells"
    
    var addNewTaskVC = AddNewTaskViewController()
    var selectedGroup = GroupType.work
    
    /* =================================================================
     *                   MARK: - Outlet Initialization
     * ================================================================= */
    @IBOutlet weak var containerView: AnimatableView!
    @IBOutlet weak var customLabel: UILabel!
    
    /* =================================================================
     *                   MARK: - Class Function
     * ================================================================= */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.customLabel.textColor = .white
        self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
    }
    
    func configure(type: GroupType, action: ActionType, task: TaskDO) {
        self.selectedGroup = type
        self.customLabel.text = type.rawValue
        
        switch action {
        case .update:
            if let enumGroup = GroupType(rawValue: task.category) {
                if enumGroup == type {
                    self.customLabel.textColor = .black
                    self.containerView.backgroundColor = .green
                    self.addNewTaskVC.taskObject.category = self.selectedGroup.rawValue
                }
            }
        default: break
        }
       
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.customLabel.textColor = .black
                self.containerView.backgroundColor = .green
                self.addNewTaskVC.taskObject.category = self.selectedGroup.rawValue
            }
            else {
                self.customLabel.textColor = .white
                self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
                self.addNewTaskVC.taskObject.category = ""
            }
           
        }
    }
}
