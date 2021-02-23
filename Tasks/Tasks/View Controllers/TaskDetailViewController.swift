//
//  TaskDetailViewController.swift
//  Tasks
//
//  Created by Lorenzo on 2/22/21.
//  Copyright © 2021 Lambda School. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    var task: Task?
    var wasEdited = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        updateViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if wasEdited {
            guard let name = nameTextField.text,
                  !name.isEmpty,
                  let task = task else { return }
            let notes = notesTextView.text
            task.name = name
            task.notes = notes
            
            let priorityIndex = priorityControl.selectedSegmentIndex
            task.priority = TaskPriority.allCases[priorityIndex].rawValue
            
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("error saving changes to context, \(error)")
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            wasEdited = true
        }
        
        nameTextField.isUserInteractionEnabled = editing
        priorityControl.isUserInteractionEnabled = editing
        notesTextView.isUserInteractionEnabled = editing
       
        navigationItem.hidesBackButton = editing
    }
    
    private func updateViews() {
        nameTextField.text = task?.name
        nameTextField.isUserInteractionEnabled = isEditing
        
        notesTextView.text = task?.notes
        notesTextView.isUserInteractionEnabled = isEditing
        
        completeButton.setImage((task?.complete ?? false) ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
        
        let priority: TaskPriority
        
        if let taskPriority = task?.priority {
            priority = TaskPriority(rawValue: taskPriority)!
        } else {
            priority = .normal
        }
        
        priorityControl.selectedSegmentIndex = TaskPriority.allCases.firstIndex(of: priority) ?? 1
        priorityControl.isUserInteractionEnabled = isEditing
    }
    
    
    @IBAction func toggleComplete(_ sender: UIButton) {
        task?.complete.toggle()
        wasEdited = true
        sender.setImage((task?.complete ?? false) ? UIImage(systemName: "checkmark.circle.fill") :
                            UIImage(systemName: "circle"),
                        for: .normal)
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    

}
