//
//  TaskRepresentation.swift
//  Tasks
//
//  Created by Lorenzo on 2/23/21.
//  Copyright © 2021 Lambda School. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable {
    // optionals for not required
    // convert to JSON-supported types
    var identifier: String
    var name: String
    var notes: String?
    var priority: String
    var complete: Bool
    
}
