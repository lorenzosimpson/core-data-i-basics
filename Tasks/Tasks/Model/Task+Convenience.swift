//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Lorenzo on 2/18/21.
//  Copyright © 2021 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Task {
    @discardableResult convenience init(id: UUID=UUID(), complete: Bool = false, notes: String?, name: String,context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.notes = notes
        self.complete = complete
    }
}
