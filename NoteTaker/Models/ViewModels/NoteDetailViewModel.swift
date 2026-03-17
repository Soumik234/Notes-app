//
//  NoteDetailViewModel.swift
//  NoteTaker
//
//  Created by Soumik Bhattacharyya on 17/03/26.
//


import Foundation
import Combine

class NoteDetailViewModel: ObservableObject {
    @Published var note: Note
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var checklistItems: [ChecklistItem] = []
    @Published var isEditingTitle: Bool = false
    
    private let dataManager = CoreDataManager.shared
    
    init(note: Note) {
        self.note = note
        self.title = note.title ?? ""
        self.content = note.content ?? ""
        self.loadChecklistItems()
    }
    
    func loadChecklistItems() {
        checklistItems = dataManager.fetchChecklistItems(for: note)
    }
    
    func saveNote() {
        dataManager.updateNote(note, title: title, content: content)
    }
    
    func addChecklistItem(title: String) {
        let nextOrder = Int16(checklistItems.count)
        dataManager.addChecklistItem(to: note, title: title, at: nextOrder)
        loadChecklistItems()
        saveNote()
    }
    
    func deleteChecklistItem(_ item: ChecklistItem) {
        dataManager.deleteChecklistItem(item)
        loadChecklistItems()
        saveNote()
    }
    
    func toggleChecklistItem(_ item: ChecklistItem) {
        dataManager.toggleChecklistItem(item)
        loadChecklistItems()
    }
    
    deinit {
        saveNote()
    }
}