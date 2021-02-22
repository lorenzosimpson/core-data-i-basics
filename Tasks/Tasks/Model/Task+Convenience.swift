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
    @discardableResult convenience init(identifier: UUID=UUID(),
                                        complete: Bool = false,
                                        notes: String?,
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
}
