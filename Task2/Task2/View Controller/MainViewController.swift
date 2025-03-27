//
//  ViewController.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-26.
//

import UIKit
import Realm
import RealmSwift
import EventKit
import IBAnimatable

class MainViewController: UIViewController {

    /* =================================================================
     *                   MARK: - Local Initialization
     * ================================================================== */
    private let barButtonSize = CGRect(x: 0, y: 0, width: 54, height: 54)
    fileprivate var dataSource: UICollectionViewDiffableDataSource<Section, TaskDO>?
    fileprivate var taskArray = [TaskDO]()
   
    lazy var realm = {
        return try! Realm()
    }()
    var taskListRealm: Results<TaskDO> {
        get {
            return self.realm.objects(TaskDO.self)
        }
    }
    
    fileprivate var buttons: [UIButton] = []
    fileprivate var selectedGroupType = String()
    
    /* =================================================================
     *                   MARK: - Outlet Initialization
     * ================================================================== */
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var allButton: AnimatableButton!
    @IBOutlet weak var workButton: AnimatableButton!
    @IBOutlet weak var errandsButton: AnimatableButton!
    @IBOutlet weak var personalButton: AnimatableButton!
    
    /* =================================================================
     *                   MARK: - Class Function
     * ================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttons = [self.allButton, self.workButton, self.errandsButton, self.personalButton]
       
        for button in self.buttons {
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            self.allButton.backgroundColor = .purple
        }
        
        self.navigationItem.title = "Dashboard"
        self.navigationItem.rightBarButtonItems =  [self.setupNewTaskBarButton()]
        self.searchBar.delegate = self
        self.setupCollectionView()
        self.getTaskArray()
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        for button in self.buttons {
            if button == sender {
                if let text = button.titleLabel?.text {
                    self.selectedGroupType = text
                    self.reloadData(taskObject: TaskDO())
                }
                button.backgroundColor = .purple
            }
            else {
                button.backgroundColor = .systemGray3
            }
        }
    }
    
    fileprivate func getTaskArray() {
        if self.taskListRealm.count > 0 {
            if self.selectedGroupType.lowercased() == "all" {
                self.taskArray = self.taskListRealm.sorted(by: { $0.creationDate > $1.creationDate })
            }
            else {
                self.taskArray = self.taskListRealm.filter({$0.category == self.selectedGroupType}).sorted(by: { $0.creationDate > $1.creationDate })
            }
        }
        else {
            self.taskArray.removeAll()
        }
        self.createDataSource()
        self.applySnapshot()
    }
    
    fileprivate func setupNewTaskBarButton() -> UIBarButtonItem {
        let newTaskButton = UIButton(type: .custom)
        newTaskButton.frame = self.barButtonSize
        newTaskButton.addTarget(self, action: #selector(onNewTaskButtonTapped), for: .touchUpInside)
        newTaskButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        newTaskButton.tintColor = .black
        return UIBarButtonItem(customView: newTaskButton)
    }
       
    fileprivate func reloadData(taskObject: TaskDO) {
        self.dismiss(animated: true)
        
        if taskObject.isReminder {
            let datetime = ("\(taskObject.deadlineDate) \(taskObject.deadlineTime)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            
            if let date = dateFormatter.date(from: datetime) {
                if let reminderIdentifier = UserDefaults.standard.string(forKey: "lastReminderIdentifier\(taskObject.uuid)") {
                    self.updateReminder(reminderIdentifier: reminderIdentifier, newTitle: taskObject.taskName, newDueDate: date)
                }
                else {
                    self.createReminder(title: taskObject.taskName, dueDate: date, uuid: taskObject.uuid)
                }
            }
        }
        self.getTaskArray()
    }
    
    @objc fileprivate func onNewTaskButtonTapped() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addNewTaskViewController") as? AddNewTaskViewController {
            viewController.onCompletionHandler = self.reloadData
            self.present(viewController, animated: true)
        }
    }
    
    fileprivate func redirectToDetailsVC(action: MenuList, indexPath: IndexPath) {
        switch action {
        case .viewDetails:
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addNewTaskViewController") as? AddNewTaskViewController {
                viewController.action = .update
                viewController.passedTaskObject = self.taskArray[indexPath.row]
                viewController.onCompletionHandler = self.reloadData
                self.present(viewController, animated: true)
            }
        case .delete: 
            let title = self.taskArray[indexPath.row].taskName
            
            try! self.realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
            }
            MessageHelper.showTopMessage(type: .toast, theme: .success, message: "Task: \(title) successfully delete")
            self.getTaskArray()
        }
    }
    
    fileprivate func createReminder(title: String, dueDate: Date, uuid: String) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .reminder) { (granted, error) in
            if granted {
                let reminder = EKReminder(eventStore: eventStore)
                reminder.title = title
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
                
                let alarm = EKAlarm(absoluteDate: dueDate)
                reminder.addAlarm(alarm)
                
                do {
                    try eventStore.save(reminder, commit: true)
                    UserDefaults.standard.set(reminder.calendarItemIdentifier, forKey: "lastReminderIdentifier\(uuid)")
                    MessageHelper.showTopMessage(type: .toast, theme: .success, message: "Reminder created successfully")
                } catch {
                    MessageHelper.showTopMessage(type: .toast, theme: .error, message: "Error updating reminder: \(error.localizedDescription)")
                }
            } else {
                MessageHelper.showTopMessage(type: .toast, theme: .info, message: "Access to reminders not granted")
            }
        }
    }
    
    fileprivate func updateReminder(reminderIdentifier: String, newTitle: String, newDueDate: Date) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .reminder) { (granted, error) in
            if granted {
                if let reminder = eventStore.calendarItem(withIdentifier: reminderIdentifier) as? EKReminder {
                    reminder.title = newTitle
                    
                    // Remove existing alarms
                    reminder.alarms?.removeAll()
                    
                    // Add new alarm
                    let newAlarm = EKAlarm(absoluteDate: newDueDate)
                    reminder.addAlarm(newAlarm)
                    
                    do {
                        try eventStore.save(reminder, commit: true)
                        MessageHelper.showTopMessage(type: .toast, theme: .success, message: "Reminder updated successfully")
                    } catch {
                        MessageHelper.showTopMessage(type: .toast, theme: .error, message: "Error updating reminder: \(error.localizedDescription)")
                    }
                }
                else {
                    MessageHelper.showTopMessage(type: .toast, theme: .info, message: "Reminder not found")
                }
            }
        }
    }
}

/* =================================================================
 *                   MARK: - UICollectionView Composition Layout
 * ================================================================== */
extension MainViewController {
    fileprivate func setupCollectionView() {
        self.registerAllNecessaryCells()
        self.collectionview.collectionViewLayout = self.createCompositionalLayout()
    }
    
    fileprivate func registerAllNecessaryCells() {
        self.collectionview.register(UINib(nibName: "TaskListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: TaskListCollectionViewCell.reuseIdentifier)
        self.collectionview.register(UINib(nibName: "TaskDateCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: TaskDateCollectionViewCell.reuseIdentifier)
    }

    fileprivate func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    fileprivate func createDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, TaskDO>(collectionView: self.collectionview) {
            collectionView, indexPath, item in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCollectionViewCell.reuseIdentifier, for: indexPath) as? TaskListCollectionViewCell else {
                fatalError("Couldn't dequeue collection view cell")
            }
            cell.configure(list: item, indexPath: indexPath)
            cell.delegate = self
            cell.onViewDetailsHandler = self.redirectToDetailsVC
            return cell
        }
    }
    
    fileprivate func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskDO>()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.taskArray)
        self.dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

extension MainViewController: TaskListCellDelegate {
    func didTapCompletedButton(at indexPath: IndexPath) {
        let modifierTask = self.taskArray[indexPath.row]
       
        if modifierTask.isCompleted {
            try! self.realm.write {
                modifierTask.isCompleted = false
                modifierTask.completedDate = ""
                self.realm.add(modifierTask, update: .modified)
            }
            MessageHelper.showTopMessage(type: .toast, theme: .success, message: "Task reopen")
        }
        else {
            try! self.realm.write {
                modifierTask.isCompleted = true
                modifierTask.completedDate = Date().toFormat("dd/MM/yyyy hh:mm:ss")
                self.realm.add(modifierTask, update: .modified)
            }
            MessageHelper.showTopMessage(type: .toast, theme: .success, message: "Task completed")
        }
        self.reloadData(taskObject: modifierTask)
    }
}

/* =================================================================
 *                   MARK: - UISearchBarDelegate
 * ================================================================== */
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 1 {
            if self.taskListRealm.count > 0 {
                if self.selectedGroupType.lowercased() == "all" {
                    self.taskArray = self.taskListRealm.filter({$0.taskName.lowercased().contains(searchText.lowercased())})
                }
                else {
                    self.taskArray = self.taskListRealm.filter({$0.taskName.lowercased().contains(searchText.lowercased()) && $0.category.lowercased() == self.selectedGroupType.lowercased()})
                }
               
                self.createDataSource()
                self.applySnapshot()
            }
        }
        else if searchText.count == 0 {
            self.reloadData(taskObject: TaskDO())
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.reloadData(taskObject: TaskDO())
    }
}
