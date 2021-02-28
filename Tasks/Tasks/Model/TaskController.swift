//
//  TaskController.swift
//  Tasks
//
//  Created by Lorenzo on 2/23/21.
//  Copyright © 2021 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!

class TaskController {
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    init() {
        fetchTasksFromServer()
    }
    
    func sendTaskToServer(task: Task, completion: @escaping CompletionHandler = {_ in }) {
        guard let uuid = task.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        
        do {
            guard let representation = task.taskRepresentation else {
                // Exit if the task can't be converted to a representation
                completion(.failure(.noRep))
                return
            }
            request.httpBody =  try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding task for PUT request, \(task), \(error)")
            completion(.failure(.noEncode))
        }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("error sending task to server, \(error)")
                completion(.failure(.otherError))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    
    
    
    func deleteTaskFromServer(task: Task, completion: @escaping CompletionHandler = {_ in}) {
        guard let uuid = task.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("error deleting task from server, \(error)")
                completion(.failure(.otherError))
                return
            }
            completion(.success(true))
        }.resume()
    }
    
    func fetchTasksFromServer(completion: @escaping CompletionHandler = {_ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("error fetching tasks, \(error)")
                completion(.failure(.otherError))
                return
            }
            guard let data = data else {
                NSLog("no data returned from firebase (fetching tasks)")
                completion(.failure(.noDecode))
                return
            }
            do {
                let taskRepresentations = Array(try JSONDecoder().decode([String : TaskRepresentation].self, from: data).values)
                try self.updateTasks(with: taskRepresentations)
            } catch {
                NSLog("error decoding data from firebase, \(error)")
                completion(.failure(.noDecode))
            }
        
        }
        .resume()
    }
    
    private func updateTasks(with representations: [TaskRepresentation]) throws {
        // map out just the IDs
        let identifiersToFetch = representations.compactMap( {UUID(uuidString: $0.identifier) })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var tasksToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        // see if DB already has the tasks fetched from firebase
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        var error: Error?
        context.performAndWait {
            do {
                let existingTasks = try context.fetch(fetchRequest)
                for task in existingTasks {
                    guard let id = task.identifier,
                          let representation = representationsByID[id] else { continue }
                    self.update(with: task, representation: representation)
                    tasksToCreate.removeValue(forKey: id)
                }
            } catch let fetchError {
                error = fetchError
            }
            
            // tasksToCreate should now contain firebase tasks that we dont have in core data
            for representation in tasksToCreate.values {
                // will create managed objects
                Task(taskRepresentation: representation, context: context)
            }
        }
        
        if let error = error { throw error } // if the error is actually set
      
        try CoreDataStack.shared.save(context: context)
        
      
    }
    
    
    
    private func update(with task: Task, representation: TaskRepresentation) {
        task.name = representation.name
        task.notes = representation.notes
        task.priority = representation.priority
        task.complete = representation.complete
        print("update called")
    }
}
