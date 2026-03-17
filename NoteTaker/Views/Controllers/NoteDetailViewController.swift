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
    @IBOutlet weak var boldButton: UIButton!
    @IBOutlet weak var italicButton: UIButton!
    @IBOutlet weak var underlineButton: UIButton!
    @IBOutlet weak var checklistButton: UIButton!
    
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
        
        boldButton.setTitle("B", for: .normal)
        boldButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        boldButton.addTarget(self, action: #selector(toggleBold), for: .touchUpInside)
        
        italicButton.setTitle("I", for: .normal)
        italicButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 16)
        italicButton.addTarget(self, action: #selector(toggleItalic), for: .touchUpInside)
        
        underlineButton.setTitle("U", for: .normal)
        underlineButton.setTitleColor(.systemBlue, for: .normal)
        underlineButton.addTarget(self, action: #selector(toggleUnderlineAction), for: .touchUpInside)
        
        checklistButton.setTitle("☑", for: .normal)
        checklistButton.addTarget(self, action: #selector(openChecklist), for: .touchUpInside)
        
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
            
            if isBold {
                let isBoldAlready = newFont.fontDescriptor.symbolicTraits.contains(.traitBold)
                let traits: UIFontDescriptor.SymbolicTraits = isBoldAlready ? [] : .traitBold
                
                if let descriptor = newFont.fontDescriptor.withSymbolicTraits(traits) {
                    newFont = UIFont(descriptor: descriptor, size: newFont.pointSize)
                }
            }
            
            if isItalic {
                let isItalicAlready = newFont.fontDescriptor.symbolicTraits.contains(.traitItalic)
                let traits: UIFontDescriptor.SymbolicTraits = isItalicAlready ? [] : .traitItalic
                
                if let descriptor = newFont.fontDescriptor.withSymbolicTraits(traits) {
                    newFont = UIFont(descriptor: descriptor, size: newFont.pointSize)
                }
            }
            
            attributedString.addAttribute(.font, value: newFont, range: attrRange)
        }
        
        contentTextView.attributedText = attributedString
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
