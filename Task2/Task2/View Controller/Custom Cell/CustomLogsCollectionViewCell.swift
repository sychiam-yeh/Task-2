//
//  CustomLogsCollectionViewCell.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-27.
//

import UIKit

class CustomLogsCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "customLogCell"
    
    /* =================================================================
     *                   MARK: - Outlet Initialization
     * ================================================================== */
    @IBOutlet weak var textLabel: UILabel!
    
    /* =================================================================
     *                   MARK: - Class Function
     * ================================================================== */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(task: TaskDO) {
        self.textLabel.text = ""
       
        var message = ""
        if !task.creationDate.isEmpty {
            message += "Created on \(task.creationDate)\n"
        }
        if !task.completedDate.isEmpty {
            message += "Completed on \(task.completedDate)\n"
        }
        self.textLabel.text = message
    }
}
