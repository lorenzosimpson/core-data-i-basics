//
//  CreateTaskViewController.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit


class CreateTaskViewController: UIViewController {

    // MARK: - Properties
    var complete: Bool = false
    
    // MARK: - IBOutlets
    
    // MARK: - View Lifecycle
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    // MARK: - Actions
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        // instantiate new task
        guard let name = nameTextField.text,
              !name.isEmpty else { return }
        let notes = notesTextView.text
        
        // The task exists on the moc, so no reference is needed
        Task(complete: complete, notes: notes, name: name)
        // save to object context
        do {
            try CoreDataStack.shared.mainContext.save()
            navigationController?.dismiss(animated: true, completion: nil)
        } catch {
            NSLog("error saving new task to moc, \(error)")
        }
    }
    
    @IBAction func toggleComplete(_ sender: UIButton) {
        complete.toggle()
        sender.setImage(complete ? UIImage(systemName: "checkmark.square.fill") :
                            UIImage(systemName: " square"),
                        for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
    }
}
