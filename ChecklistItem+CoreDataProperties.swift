//
//  ChecklistItem+CoreDataProperties.swift
//  NoteTaker
//
//  Created by Soumik Bhattacharyya on 17/03/26.
//
//

public import Foundation
public import CoreData


public typealias ChecklistItemCoreDataPropertiesSet = NSSet

extension ChecklistItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChecklistItem> {
        return NSFetchRequest<ChecklistItem>(entityName: "ChecklistItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var order: Int16
    @NSManaged public var title: String?
    @NSManaged public var note: Note?

}

extension ChecklistItem : Identifiable {

}
