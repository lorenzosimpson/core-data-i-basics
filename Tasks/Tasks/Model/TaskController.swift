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
}
