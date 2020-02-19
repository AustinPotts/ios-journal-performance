//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        
        //MARK: - Print the time it takes to Sync
        let startTime = CFAbsoluteTimeGetCurrent()
        var count = 1
        print("Syncing: \(startTime)")
        
        self.context.perform {
            self.update(with: entries)
            //MARK: - This code needs to be re configured
//            for entryRep in entries {
//                guard let identifier = entryRep.identifier else { continue }
//
//                let entry = self.fetchSingleEntryFromPersistentStore(with: identifier, in: self.context)
//                if let entry = entry, entry != entryRep {
//                    self.update(entry: entry, with: entryRep)
//                } else if entry == nil {
//                    _ = Entry(entryRepresentation: entryRep, context: self.context)
//                }
//            }
//            completion(nil)
            
            print("Finish \(count): \(CFAbsoluteTimeGetCurrent() - startTime)")
            count += 1
           
        }
    }
    
    // MARK: - Configured Update method to check for existing entries 
  func update(with representations: [EntryRepresentation]) {

    
    
         let identifiersToFetch = representations.map { $0.identifier }

          let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))

   
    
          var entriesToCreate = representationsByID

          let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
  
          fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
    
          let context = CoreDataStack.shared.container.newBackgroundContext()
    
         
         context.performAndWait {
            do {
              let existingEntries = try context.fetch(fetchRequest)
             
                for entry in existingEntries {

                                    
                guard let identifier = entry.identifier,
                let representation = representationsByID[identifier] else { continue }
               
                entry.title = representation.title
                entry.bodyText = representation.bodyText
                entry.mood = representation.mood


                entriesToCreate.removeValue(forKey: identifier)

                }
                // Which ones do we not have
                var entryCount = 1
                for representation in entriesToCreate.values {
                Entry(entryRepresentation: representation, context: context)
                entryCount += 1
                }
                try context.save()
                print("Created: \(entryCount) entries")
                
            } catch {
                print("Error fetching entry \(error)")
            }
        }
    }
    
    private func fetchSingleEntryFromPersistentStore(with identifier: String?, in context: NSManagedObjectContext) -> Entry? {
        
        guard let identifier = identifier else { return nil }
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var result: Entry? = nil
        do {
            result = try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        return result
    }
    
    let context: NSManagedObjectContext
}



       
     




   
