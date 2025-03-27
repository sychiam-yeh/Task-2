//
//  TaskListCollectionViewCell.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-26.
//

import UIKit
import EventKit

enum MenuList: String, CaseIterable {
    case viewDetails = "View Details"
    case delete = "Delete"
}

protocol TaskListCellDelegate: AnyObject {
    func didTapDateButton(at indexPath: IndexPath)
    func didTapCompletedButton(at indexPath: IndexPath)
}

class TaskListCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "taskListCell"
    
    /* =================================================================
     *                   MARK: - Local Initialization
     * ================================================================== */
    weak var delegate: TaskListCellDelegate?
    
    fileprivate var indexPath = IndexPath()
    var onViewDetailsHandler: ((MenuList, IndexPath) -> Void)?
    
    /* =================================================================
     *                   MARK: - Outlet Initialization
     * ================================================================== */
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bellImageView: UIImageView!
    
    @IBAction func onCompleteButtonTapped(_ sender: Any) {
        self.delegate?.didTapCompletedButton(at: self.indexPath)
    }
    
    @IBAction func onMoreButtonTapped(_ sender: Any) {
        self.setupUIMenu()
    }
    
    @IBAction func onDateButtonTapped(_ sender: Any) {
        self.delegate?.didTapDateButton(at: self.indexPath)
    }
   
    
    /* =================================================================
     *                   MARK: - Class Function
     * ================================================================== */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bellImageView.isHidden = true
    }
    
    func configure(list: TaskDO, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.titleLabel.text = list.title
        self.descLabel.text = list.titleDescription
        self.dateLabel.text = "\(list.deadlineDate) \(list.deadlineTime)"
        
        self.bellImageView.isHidden = true
        if list.isReminder {
            self.bellImageView.isHidden = false
        }
    }
    
    fileprivate func setupUIMenu() {
        let layoutActions = MenuList.allCases
        var layoutPatternAction = [UIAction]()
        
        for eachAction in layoutActions {
            let action = UIAction(title: eachAction.rawValue) {  _ in
                self.handleSelectionSalesAction(action: eachAction, indexPath: self.indexPath)
            }
            layoutPatternAction.append(action)
        }
        self.moreButton.menu = UIMenu(title: "More", children: layoutPatternAction)
        self.moreButton.showsMenuAsPrimaryAction = true
    }
    
    fileprivate func handleSelectionSalesAction(action: MenuList, indexPath: IndexPath) {
        self.onViewDetailsHandler?(action, indexPath)
    }
}
