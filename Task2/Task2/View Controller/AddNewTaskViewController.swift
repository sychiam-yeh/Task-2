//
//  AddNewTaskViewController.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-26.
//

import UIKit
import RealmSwift
import Realm
import SwiftDate
import EventKit

enum Section {
    case main
}

enum SectionLayout: CaseIterable {
    case title
    case description
    case deadline
}

enum ActionType {
    case add
    case update
}

enum TaskField: CaseIterable {
    case taskName
    case descName
   
    var stringValue: String {
        switch self {
        case .taskName:
            return "Please enter to add task"
        case .descName:
            return "Description"
        }
    }
    
    static let titleArray = [taskName]
    static let descArray = [descName]
}

class AddNewTaskViewController: UIViewController {

    /* =================================================================
     *                   MARK: - Local Initialization
     * ================================================================== */
    fileprivate var sectionLayout = SectionLayout.allCases
    fileprivate var dataSource: UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>?
    
    var onCompletionHandler: ((TaskDO) -> Void)?
    var taskObject = TaskDO()
    var action = ActionType.add
    var passedTaskObject = TaskDO()
    
    lazy var realm = {
        return try! Realm()
    }()
    
    /* =================================================================
     *                   MARK: - Outlet Initialization
     * ================================================================== */
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onSaveTapped(_ sender: Any) {
        if !self.taskObject.title.isEmpty || self.taskObject.title != "" {
           
            try! self.realm.write {
                switch self.action {
                case .add:
                    self.taskObject.creationDate = Date().toFormat("dd/MM/yyyy HH:mm:ss")
                    self.realm.add(self.taskObject)
                case .update:
                    self.taskObject.uuid = self.passedTaskObject.uuid
                    self.taskObject.creationDate = self.passedTaskObject.creationDate
                    self.realm.add(self.taskObject, update: .modified)
                }
            }
            self.onCompletionHandler?(self.taskObject)
        }
        else {
            MessageHelper.showTopMessage(type: .toast, theme: .info, message: "Add task is required.")
        }
    }
    
    /* =================================================================
     *                   MARK: - Class Function
     * ================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setupCollectionView()
    }
}

/* =================================================================
 *                   MARK: - UICollectionView Composition Layout
 * ================================================================== */
extension AddNewTaskViewController {
    fileprivate func setupCollectionView() {
        self.registerAllNecessaryCells()
        self.collectionview.collectionViewLayout = self.createCompositionalLayout()
        self.configureCollectionViewDataSource()
        self.applySnapshot()
    }
    
    fileprivate func registerAllNecessaryCells() {
        self.collectionview.register(UINib(nibName: "NewTaskCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: NewTaskCollectionViewCell.reuseIdentifier)
        self.collectionview.register(UINib(nibName: "TaskDateCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: TaskDateCollectionViewCell.reuseIdentifier)
    }
 
    fileprivate func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return self.createComponentSection(sectionIndex: sectionIndex)
        }
        return layout
    }
    
    fileprivate func createComponentSection(sectionIndex: Int) -> NSCollectionLayoutSection {
        let sectionType = self.sectionLayout[sectionIndex]
        switch sectionType {
            
        case SectionLayout.title, SectionLayout.description :
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        case SectionLayout.deadline:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
    }
    
    fileprivate func configureCollectionViewDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>(collectionView: self.collectionview) { collectionView, indexPath, item in
            let sectionType = self.sectionLayout[indexPath.section]
            
            switch sectionType {
                
            case SectionLayout.title, SectionLayout.description :
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewTaskCollectionViewCell.reuseIdentifier, for: indexPath) as? NewTaskCollectionViewCell else {
                    fatalError("Couldn't dequeue collection view cell")
                }
                
                cell.addNewTaskVC = self
                cell.textField.tag = indexPath.section
               
                if let value = item as? TaskField {
                    cell.configure(value: value, action: self.action, task: self.passedTaskObject)
                }
                return cell
            case SectionLayout.deadline:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDateCollectionViewCell.reuseIdentifier, for: indexPath) as? TaskDateCollectionViewCell else {
                    fatalError("Couldn't dequeue collection view cell")
                }
                cell.addNewTaskVC = self
                cell.configure(task: self.passedTaskObject, action: self.action)
               
                
                return cell
            }
        }
    }
    
    fileprivate func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<AnyHashable, AnyHashable>()
        snapshot.appendSections(self.sectionLayout)

        for eachSection in self.sectionLayout {
            switch eachSection {
            case SectionLayout.title:
                snapshot.appendItems([TaskField.taskName], toSection: eachSection)
            case SectionLayout.description:
                snapshot.appendItems([TaskField.descName], toSection: eachSection)
            case SectionLayout.deadline:
                snapshot.appendItems([3], toSection: eachSection)
            }
        }
        self.dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
