//
//  CoreDataStack.swift
//  PokeTeam
//
//  Created by Jon Duenas on 9/20/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataStack {
    public static let modelName = "PokeTeam"
    
    public static let managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: CoreDataStack.self)
        return NSManagedObjectModel.mergedModel(from: [bundle])!
    }()
    
    public init() {}
    
    public lazy var mainContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: CoreDataStack.managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            container.viewContext.automaticallyMergesChangesFromParent = true
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    public func newDerivedContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    public func saveContext() {
        saveContext(mainContext)
    }
    
    public func saveContext(_ context: NSManagedObjectContext) {
        if context != mainContext {
            saveDerivedContext(context)
            return
        }
        
        context.performAndWait {
            do {
                try context.save()
                print("Core Data main context saved.")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func saveDerivedContext(_ context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
                print("Core Data derived context saved.")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            self.saveContext(self.mainContext)
        }
    }
    
    public func deletePersistentStore() {
        guard let url = persistentContainer.persistentStoreDescriptions.first?.url else { return }
        
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        mainContext.performAndWait {
            mainContext.reset()
            
            do {
                try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
            } catch {
                print("Attempted to clear persistent store: " + error.localizedDescription)
            }
            
            persistentContainer.loadPersistentStores { [weak self] (storeDescription, error) in
                guard let self = self else { return }
                
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                } else {
                    self.saveContext()
                    self.mainContext = self.persistentContainer.viewContext
                }
            }
        }
    }
}
