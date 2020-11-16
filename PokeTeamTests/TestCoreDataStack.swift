//
//  TestCoreDataStack.swift
//  PokeTeamTests
//
//  Created by Jon Duenas on 9/20/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation
import CoreData
import PokeTeam

class TestCoreDataStack: CoreDataStack {
    override init() {
        super.init()
        
        let model = CoreDataStack.managedObjectModel
        precondition(!model.entities.isEmpty)
        
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { _, error in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            container.viewContext.automaticallyMergesChangesFromParent = true
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        persistentContainer = container
    }
}
