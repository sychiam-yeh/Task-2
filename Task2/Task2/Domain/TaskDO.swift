//
//  TaskDO.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-26.
//

import Foundation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm

class TaskDO: Object, Mappable {
    @objc dynamic var uuid = UUID().uuidString
    @objc dynamic var title = String()
    @objc dynamic var titleDescription = String()
    @objc dynamic var deadlineDate = String()
    @objc dynamic var deadlineTime = String()
    @objc dynamic var isCompleted: Bool = false
    @objc dynamic var completedDate = String()
    @objc dynamic var isReminder: Bool = false
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var creationDate = String()
    @objc dynamic var category = String()
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    func mapping(map: ObjectMapper.Map) {
        uuid <- map["uuid"]
        title <- map["taskName"]
        titleDescription <- map["description"]
        deadlineDate <- map["deadlineDate"]
        deadlineTime <- map["deadlineTime"]
        isCompleted <- map["isCompleted"]
        completedDate <- map["completedDate"]
        isReminder <- map["isReminder"]
        isDeleted <- map["isDeleted"]
        creationDate <- map["creationDate"]
        category <- map["category"]
    }
}

class TaskLogs: Object, Mappable {
    @objc dynamic var title = String()
    @objc dynamic var logs = String()
   
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        title <- map["taskName"]
        logs <- map["logs"]
       
    }
}
