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
    
    /* =================================================================
     *                   MARK: - Outlet Initialization
     * ================================================================== */
    @IBOutlet weak var collectionview: UICollectionView!
    
    
    /* =================================================================
     *                   MARK: - Class Function
     * ================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Dashboard"
        self.navigationItem.rightBarButtonItems =  [self.setupNewTaskBarButton()]
        
        self.setupCollectionView()
        self.getTaskArray()
    }
    
    fileprivate func getTaskArray() {
        if self.taskListRealm.count > 0 {
            self.taskArray = self.taskListRealm.filter({$0.isDeleted == false && $0.isCompleted == false}).sorted(by: { $0.creationDate > $1.creationDate })
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
                    self.updateReminder(reminderIdentifier: reminderIdentifier, newTitle: taskObject.title, newDueDate: date)
                }
                else {
                    self.createReminder(title: taskObject.title, dueDate: date, uuid: taskObject.uuid)
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
            let title = self.taskArray[indexPath.row].title
            
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
    func didTapDateButton(at indexPath: IndexPath) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "customDateViewController") as? CustomDateViewController {
            viewController.modalPresentationStyle = .formSheet
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func didTapCompletedButton(at indexPath: IndexPath) {
        try! self.realm.write {
            let modifierTask = self.taskArray[indexPath.row]
            modifierTask.isCompleted = true
            self.realm.add(modifierTask, update: .modified)
        }
        MessageHelper.showTopMessage(type: .toast, theme: .success, message: "TASK COMPLETED")
//        self.reloadData()
    }
}
