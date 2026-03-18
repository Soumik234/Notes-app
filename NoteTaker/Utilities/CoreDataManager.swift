//
//  CoreDataManager.swift
//  NoteTaker
//
//  Created by Soumik Bhattacharyya on 17/03/26.
//


import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoteTaker")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Error saving context: \(nserror.localizedDescription)")
            }
        }
    }
    
    func fetchAllNotes() -> [Note] {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Note.modifiedDate, ascending: false)
        ]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching notes: \(error.localizedDescription)")
            return []
        }
    }
    
    func createNote(title: String = "", content: String = "") -> Note {
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: viewContext) as! Note
        note.id = UUID()
        note.title = title
        note.content = content
        note.createdDate = Date()
        note.modifiedDate = Date()
        note.isFavorite = false
        
        saveContext()
        return note
    }
    
    func deleteNote(_ note: Note) {
        viewContext.delete(note)
        saveContext()
    }
    
    func updateNote(_ note: Note, title: String, content: String) {
        note.title = title
        note.content = content
        note.modifiedDate = Date()
        saveContext()
    }
    
}
