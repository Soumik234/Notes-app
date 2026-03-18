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
            style: .prominent,
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

    private func insertCheckbox() {
        let checkboxText = "☐ "
        let selectedRange = contentTextView.selectedRange
        let updatedText = NSMutableString(string: contentTextView.text ?? "")
        updatedText.insert(checkboxText, at: selectedRange.location)
        contentTextView.text = updatedText as String
        contentTextView.selectedRange = NSRange(location: selectedRange.location + checkboxText.count, length: 0)
        viewModel.content = contentTextView.text
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
    
    // MARK: - Checklist Properties
    private var isChecklistMode = false

    @objc func openChecklist() {
        isChecklistMode = true
        insertChecklistItem()
    }

    private func insertChecklistItem(at location: Int? = nil) {
        let attachment = makeCircularCheckboxAttachment(checked: false)
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        
        // Add a space after the checkbox
        let spaceAttr = NSMutableAttributedString(string: " ")
        spaceAttr.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: 1))
        attachmentString.append(spaceAttr)
        
        let insertLocation = location ?? contentTextView.selectedRange.location
        let fullText = NSMutableAttributedString(attributedString: contentTextView.attributedText)
        
        // Prepend newline if not at start and previous char isn't newline
        if insertLocation > 0 {
            let prevChar = (fullText.string as NSString).substring(with: NSRange(location: insertLocation - 1, length: 1))
            if prevChar != "\n" {
                let newline = NSAttributedString(string: "\n")
                fullText.insert(newline, at: insertLocation)
                fullText.insert(attachmentString, at: insertLocation + 1)
                contentTextView.attributedText = fullText
                contentTextView.selectedRange = NSRange(location: insertLocation + 1 + attachmentString.length, length: 0)
                return
            }
        }
        
        fullText.insert(attachmentString, at: insertLocation)
        contentTextView.attributedText = fullText
        contentTextView.selectedRange = NSRange(location: insertLocation + attachmentString.length, length: 0)
        viewModel.content = contentTextView.text
    }

    private func makeCircularCheckboxAttachment(checked: Bool) -> NSTextAttachment {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 1.5, dy: 1.5)
            let context = ctx.cgContext
            
            if checked {
                // Filled circle with checkmark
                UIColor.systemBlue.setFill()
                context.fillEllipse(in: rect)
                // Draw checkmark
                UIColor.white.setStroke()
                context.setLineWidth(2)
                context.setLineCap(.round)
                context.setLineJoin(.round)
                let checkPath = UIBezierPath()
                checkPath.move(to: CGPoint(x: size.width * 0.25, y: size.height * 0.5))
                checkPath.addLine(to: CGPoint(x: size.width * 0.45, y: size.height * 0.7))
                checkPath.addLine(to: CGPoint(x: size.width * 0.75, y: size.height * 0.3))
                checkPath.stroke()
            } else {
                // Empty circle
                UIColor.systemGray3.setStroke()
                context.setLineWidth(1.5)
                context.strokeEllipse(in: rect)
            }
        }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: -4, width: 20, height: 20)
        return attachment
    }
}

extension NoteDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.content = textView.text
    }
}

extension NoteDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        return true
    }
}
