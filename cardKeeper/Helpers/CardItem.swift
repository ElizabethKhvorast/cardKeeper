//
//  CardItem.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 13/03/2023.
//

import UIKit

struct CardItem
{
    var barcode: String?
    var image: UIImage?
    var title: String?
    var createdAt: Date?
    var isFavorite = false
    
    init(barcode: String?, image: UIImage?)
    {
        self.barcode = barcode
        self.image = image
    }
    
    init(with entity: CardEntity)
    {
        self.barcode = entity.barcode
        if let data = entity.image
        {
            self.image = UIImage(data: data)
        }
        self.title = entity.title
        self.createdAt = entity.createdAt
        self.isFavorite = entity.isFavorite
    }
    
    func save()
    {
        CardEntity.save(self)
    }
    
    static func getAll() -> [CardItem]
    {
        var temp = [CardItem]()
        if let existingEntities = CardEntity.getAllItems()
        {
            for eachEntity in existingEntities
            {
                temp.append(CardItem(with: eachEntity))
            }
        }
        return temp
    }
}
