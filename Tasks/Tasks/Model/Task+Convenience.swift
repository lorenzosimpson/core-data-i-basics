//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Lorenzo on 2/18/21.
//  Copyright © 2021 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum TaskPriority: String, CaseIterable {
    case low
    case normal
    case high
    case critical
}

extension Task {
    // Enable a task to be able to convert itself into a TaskRepresentation object
    var taskRepresentation: TaskRepresentation? {
        guard let id = identifier, let name = name,
              let priority = priority else { return nil }
        
        return TaskRepresentation(identifier: id.uuidString,
                                  name: name,
                                  notes: notes,
                                  priority: priority,
                                  complete: complete)
    }
    
    
    @discardableResult convenience init(identifier: UUID=UUID(),
                                        complete: Bool = false,
                                        notes: String? = nil,
                                        name: String,
                                        priority: TaskPriority = .normal,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.name = name
        self.notes = notes
        self.complete = complete
        self.priority = priority.rawValue
    }
    
    
    @discardableResult convenience init?(taskRepresentation: TaskRepresentation, context: NSManagedObjectContext=CoreDataStack.shared.mainContext) {
        guard let identifier = UUID(uuidString: taskRepresentation.identifier),
              let priority = TaskPriority(rawValue: taskRepresentation.priority) else { return nil }
        
        self.init(identifier: identifier, complete: taskRepresentation.complete, notes: taskRepresentation.notes, name: taskRepresentation.name, priority: priority, context: context)
    }
}
