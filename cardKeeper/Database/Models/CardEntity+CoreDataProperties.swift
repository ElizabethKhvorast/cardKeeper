//
//  CardEntity+CoreDataProperties.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 13/03/2023.
//
//

import Foundation
import CoreData

extension CardEntity
{
    public class func fetchRequest() -> NSFetchRequest<CardEntity>
    {
        return NSFetchRequest<CardEntity>(entityName: "CardEntity")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var image: Data?
    @NSManaged public var title: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isFavorite: Bool
}

