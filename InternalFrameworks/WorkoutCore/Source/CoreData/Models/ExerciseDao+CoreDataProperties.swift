//
//  ExerciseDao+CoreDataProperties.swift
//  WorkoutCore
//
//  Created by Tsonev Ivaylo on 16.10.20.
//  Copyright © 2020 tsonevInc. All rights reserved.
//
//

import Foundation
import CoreData


extension ExerciseDao {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseDao> {
        return NSFetchRequest<ExerciseDao>(entityName: "ExerciseDao")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String
    @NSManaged public var imageKey: String
    @NSManaged public var thumbnailKey: String

}

extension ExerciseDao : Identifiable {

}
