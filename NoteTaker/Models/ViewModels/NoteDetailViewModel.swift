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
    
    private let dataManager = CoreDataManager.shared
    
    init(note: Note) {
        self.note = note
        self.title = note.title ?? ""
        self.content = note.content ?? ""
    }
    
    func saveNote() {
        dataManager.updateNote(note, title: title, content: content)
    }
    
    
    deinit {
        saveNote()
    }
}
