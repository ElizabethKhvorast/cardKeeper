//
//  CardEntity+CoreDataClass.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 13/03/2023.
//
//

import Foundation
import CoreData

public class CardEntity: NSManagedObject
{
    func update(with model: CardItem)
    {
        self.barcode = model.barcode
        self.image = model.image?.jpegData(compressionQuality: 1)
        self.title = model.title
        self.createdAt = model.createdAt
        self.isFavorite = model.isFavorite
    }
    
    class func save(_ model: CardItem)
    {
        if let existingEntity = self.getItemBy(model.barcode)
        {
            existingEntity.update(with: model)
        }
        else if let newEntity = NSEntityDescription.insertNewObject(forEntityName: "CardEntity", into: DataManager.shared.managedObjectContext) as? CardEntity
        {
            newEntity.update(with: model)
        }
        DataManager.shared.saveMain()
    }
    
    class func getItemBy(_ barcode: String?) -> CardEntity?
    {
        guard let code = barcode else {
            return nil
        }
        let fetchRequest = CardEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "barcode == %@", code)
        do
        {
            let object = try DataManager.shared.managedObjectContext.fetch(fetchRequest).first
            return object
        }
        catch
        {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    class func getAllItems() -> [CardEntity]?
    {
        let fetchRequest = CardEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do
        {
            let objects = try DataManager.shared.managedObjectContext.fetch(fetchRequest)
            return objects
        }
        catch
        {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
}
