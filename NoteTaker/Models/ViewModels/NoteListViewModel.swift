//
//  NoteListViewModel.swift
//  NoteTaker
//
//  Created by Soumik Bhattacharyya on 17/03/26.
//

import Foundation
import Combine

class NoteListViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    private let dataManager = CoreDataManager.shared
    
    func loadNotes() {
        isLoading = true
        DispatchQueue.main.async {
            let allNotes = self.dataManager.fetchAllNotes()
            self.notes = self.searchText.isEmpty ?
                allNotes :
                self.filterNotes(allNotes)
            self.isLoading = false
        }
    }
    
    func filterNotes(_ allNotes: [Note]) -> [Note] {
        guard !searchText.isEmpty else { return allNotes }
        return allNotes.filter { note in
            (note.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (note.content?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    func createNewNote() -> Note {
        return dataManager.createNote(title: "New Note", content: "")
    }
    
    func deleteNote(_ note: Note) {
        dataManager.deleteNote(note)
        loadNotes()
    }
    
    func toggleFavorite(for note: Note) {
        note.isFavorite = !note.isFavorite
        dataManager.updateNote(note, title: note.title ?? "", content: note.content ?? "")
    }
}
