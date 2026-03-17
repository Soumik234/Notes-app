//
//  ChecklistViewController.swift
//  NoteTaker
//
//  Created by Soumik Bhattacharyya on 17/03/26.
//


import UIKit
import Combine

class ChecklistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addItemTextField: UITextField!
    @IBOutlet weak var addItemButton: UIButton!
    
    var viewModel: NoteDetailViewModel!
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    func setupUI() {
        title = "Checklist"
        tableView.delegate = self
        tableView.dataSource = self
        
        addItemButton.addTarget(self, action: #selector(addChecklistItem), for: .touchUpInside)
        addItemTextField.placeholder = "Add checklist item..."
    }
    
    func setupBindings() {
        viewModel.$checklistItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addChecklistItem() {
        guard let text = addItemTextField.text, !text.isEmpty else { return }
        viewModel.addChecklistItem(title: text)
        addItemTextField.text = ""
    }
}

extension ChecklistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.checklistItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath)
        let item = viewModel.checklistItems[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        
        let attributes: [NSAttributedString.Key: Any] = 
            item.isCompleted ? 
            [.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)] : [:]
        
        config.attributedText = NSAttributedString(
            string: item.title ?? "",
            attributes: attributes
        )
        
        cell.accessoryType = item.isCompleted ? .checkmark : .none
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.checklistItems[indexPath.row]
        viewModel.toggleChecklistItem(item)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            let item = self?.viewModel.checklistItems[indexPath.row]
            if let item = item {
                self?.viewModel.deleteChecklistItem(item)
            }
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}