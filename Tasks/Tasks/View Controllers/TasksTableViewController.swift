//
//  TasksTableViewController.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {

    // MARK: - Properties
    
    let taskController = TaskController()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        let context = CoreDataStack.shared.mainContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: "priority",
                                             cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            NSLog("error with initial fetch, \(error)")
        }
        return frc
    }()
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath) as? TaskTableViewCell else { fatalError("can't dequeue cell of type \(TaskTableViewCell.reuseIdentifier)")}
        
        cell.task = fetchedResultsController.object(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        return sectionInfo.name.capitalized
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = fetchedResultsController.object(at: indexPath)
            taskController.deleteTaskFromServer(task: task) { (result) in
                // throwable method as optional. does result.get() produce a value? or nil
                // don't care about the value, not storing it
                
                
                guard let _ = try? result.get() else { return }
                // if Firebase deletion works, continue and delete it locally.
                DispatchQueue.main.async {
                    let context = CoreDataStack.shared.mainContext
                    context.delete(task)
                    
                    do {
                        try context.save()
                    } catch {
                        context.reset()
                        NSLog("error saving managed object context, \(error)")
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let detailVC = segue.destination as? TaskDetailViewController {
                guard let indexPath = tableView.indexPathForSelectedRow else { return }
                detailVC.task = fetchedResultsController.object(at: indexPath)
                detailVC.taskController = taskController
            }
        } else if segue.identifier == "CreateTaskModalSegue" {
            // going to nav controller, NOT create
            if let navC = segue.destination as? UINavigationController, let createTaskVC = navC.viewControllers.first as? CreateTaskViewController {
                createTaskVC.taskController = taskController
            }
        }
    }
        
}

extension TasksTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates() // put table into editing mode
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates() // done making changes
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
}
