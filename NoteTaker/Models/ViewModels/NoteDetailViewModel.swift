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
    @Published var isEditingTitle: Bool = false

    let isNew: Bool
    private(set) var didSave: Bool = false
    
    private let dataManager = CoreDataManager.shared
    
    init(note: Note, isNew: Bool = false) {
        self.note = note
        self.title = note.title ?? ""
        self.content = note.content ?? ""
        self.isNew = isNew
    }
    
    func saveNote() {
        dataManager.updateNote(note, title: title, content: content)
        didSave = true
    }

    func discardNoteIfNeeded() {
        guard isNew, !didSave else { return }
        dataManager.deleteNote(note)
    }
}
