//
//  DataManager.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 13/03/2023.
//

import Foundation
import CoreData

/*
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html#//apple_ref/doc/uid/TP40001075-CH4-SW1
 */

class DataManager
{
    static let shared = DataManager()
    
    var persistentContainer: NSPersistentContainer
    var managedObjectContext: NSManagedObjectContext {
        get {
            return self.persistentContainer.viewContext
        }
    }
    
    init(_ completionClosure: @escaping () -> ())
    {
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last,
              let storeURL = URL(string: "DataBase.sqlite", relativeTo: fileURL) else {
            fatalError("Unable to resolve document directory")
        }
                    
        self.persistentContainer = NSPersistentContainer(name: "DataModel")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        self.persistentContainer.persistentStoreDescriptions = [description]
        self.persistentContainer.loadPersistentStores() {[weak self] (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            self?.persistentContainer.viewContext.shouldDeleteInaccessibleFaults = true
            self?.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            self?.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            completionClosure()
        }
    }
    
    convenience init()
    {
        self.init {
            print("DataManager init")
        }
    }
    
//    func workerContext() -> NSManagedObjectContext
//    {
//        return self.persistentContainer.newBackgroundContext()
//    }
    
    func saveMain()
    {
        self.managedObjectContext.performAndWait { [weak self] in
            do
            {
                try self?.managedObjectContext.save()
            }
            catch
            {
                debugPrint("Failure to save context", error)
            }
        }
    }
}
