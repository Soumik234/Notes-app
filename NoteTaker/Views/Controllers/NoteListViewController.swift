//
//  NoteListViewController.swift
//  NoteTaker
//
//  Created by Soumik Bhattacharyya on 17/03/26.
//


import UIKit
import Combine

class NoteListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var viewModel = NoteListViewModel()
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadNotes()
    }
    
    func setupUI() {
        title = "Notes"
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNoteTapped)
        )
    }
    
    func setupBindings() {
        viewModel.$notes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addNoteTapped() {
        let newNote = viewModel.createNewNote()
        navigateToNoteDetail(note: newNote)
    }
    
    func navigateToNoteDetail(note: Note) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(
            withIdentifier: "NoteDetailViewController"
        ) as! NoteDetailViewController
        detailVC.viewModel = NoteDetailViewModel(note: note)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension NoteListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let note = viewModel.notes[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = note.title?.isEmpty == false ? note.title : "Untitled"

        // Show only first 2 lines / 100 chars of content
        let rawContent = note.content ?? ""
        let lines = rawContent
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let preview: String
        if lines.isEmpty {
            preview = "No additional text"
        } else {
            let firstTwo = lines.prefix(2).joined(separator: " · ")
            preview = firstTwo.count > 100 ? String(firstTwo.prefix(100)) + "…" : firstTwo
        }

        config.secondaryText = preview
        config.secondaryTextProperties.numberOfLines = 2
        config.secondaryTextProperties.lineBreakMode = .byTruncatingTail

        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedNote = viewModel.notes[indexPath.row]
        navigateToNoteDetail(note: selectedNote)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            let note = self?.viewModel.notes[indexPath.row]
            if let note = note {
                self?.viewModel.deleteNote(note)
            }
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

extension NoteListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        viewModel.loadNotes()
    }
}
