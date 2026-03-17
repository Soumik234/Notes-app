//
//  NoteDetailViewController.swift
//  NoteTaker
//
//  Created by Soumik Bhattacharyya on 17/03/26.
//


import UIKit
import Combine

class NoteDetailViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var boldButton: UIBarButtonItem!
    @IBOutlet weak var italicButton: UIBarButtonItem!
    @IBOutlet weak var underlineButton: UIBarButtonItem!
    @IBOutlet weak var checklistButton: UIBarButtonItem!
    
    var viewModel: NoteDetailViewModel!
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupTextViewDelegate()
    }
    
    func setupUI() {
        title = "Edit Note"
        titleTextField.text = viewModel.title
        contentTextView.text = viewModel.content
        contentTextView.font = UIFont.systemFont(ofSize: 16)
        
        boldButton.target = self
        boldButton.action = #selector(toggleBold)
        italicButton.target = self
        italicButton.action = #selector(toggleItalic)
        underlineButton.target = self
        underlineButton.action = #selector(toggleUnderlineAction)
        checklistButton.target = self
        checklistButton.action = #selector(openChecklist)
        
        titleTextField.addTarget(self, action: #selector(titleTextChanged), for: .editingChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    func setupBindings() {
        viewModel.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleTextField.text = title
            }
            .store(in: &cancellables)
    }
    
    func setupTextViewDelegate() {
        contentTextView.delegate = self
    }
    
    @objc private func titleTextChanged() {
        viewModel.title = titleTextField.text ?? ""
    }
    
    @objc func toggleBold() {
        applyFormatting(isBold: true)
    }
    
    @objc func toggleItalic() {
        applyFormatting(isItalic: true)
    }
    
    @objc private func toggleUnderlineAction() {
        let range = contentTextView.selectedRange
        guard range.length > 0 else { return }
        
        let attributedString = NSMutableAttributedString(attributedString: contentTextView.attributedText)
        
        attributedString.enumerateAttribute(.underlineStyle, in: range, options: []) { value, attrRange, _ in
            if value != nil {
                attributedString.removeAttribute(.underlineStyle, range: attrRange)
            } else {
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: attrRange)
            }
        }
        
        contentTextView.attributedText = attributedString
    }
    
    @objc func openChecklist() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let checklistVC = storyboard.instantiateViewController(withIdentifier: "ChecklistViewController") as! ChecklistViewController
        checklistVC.viewModel = viewModel
        navigationController?.pushViewController(checklistVC, animated: true)
    }
    
    func applyFormatting(isBold: Bool = false, isItalic: Bool = false) {
        let range = contentTextView.selectedRange
        guard range.length > 0 else { return }

        let attributedString = NSMutableAttributedString(attributedString: contentTextView.attributedText)
        let baseFont = UIFont.systemFont(ofSize: 16)

        attributedString.enumerateAttribute(.font, in: range, options: []) { existingFont, attrRange, _ in
            var newFont = existingFont as? UIFont ?? baseFont
            var traits = newFont.fontDescriptor.symbolicTraits

            if isBold {
                if traits.contains(.traitBold) {
                    traits.remove(.traitBold)
                } else {
                    traits.insert(.traitBold)
                }
            }

            if isItalic {
                if traits.contains(.traitItalic) {
                    traits.remove(.traitItalic)
                } else {
                    traits.insert(.traitItalic)
                }
            }

            if let descriptor = newFont.fontDescriptor.withSymbolicTraits(traits) {
                newFont = UIFont(descriptor: descriptor, size: newFont.pointSize)
            }

            attributedString.addAttribute(.font, value: newFont, range: attrRange)
        }

        contentTextView.attributedText = attributedString
        contentTextView.selectedRange = range  // ✅ restore selection
    }
    
    @objc func saveTapped() {
        viewModel.title = titleTextField.text ?? ""
        viewModel.content = contentTextView.text
        viewModel.saveNote()
        navigationController?.popViewController(animated: true)
    }
}

extension NoteDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.content = textView.text
    }
}
