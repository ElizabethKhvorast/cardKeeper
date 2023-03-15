//
//  CardDataSource.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 13/03/2023.
//

import Foundation

struct CardSection
{
    let items: [CardItem]
    let title: String
}

class CardDataSource
{
    private var items = [CardItem]()
    var sections = [CardSection]()
    
    var hasItems: Bool {
        get {
            return self.items.count > 0
        }
    }
    
    func update(_ completion: ()->Void)
    {
        self.items = CardItem.getAll()
        self.sections.removeAll()
        let favorites = self.items.filter({$0.isFavorite == true})
        if favorites.count > 0
        {
            self.sections.append(CardSection(items: favorites, title: "Favorite"))
            let recents = self.items.filter({$0.isFavorite == false})
            if recents.count > 0
            {
                self.sections.append(CardSection(items: recents, title: "Recent"))
            }
        }
        else
        {
            let sorted = self.items.sorted { one, two in
                if let first = one.createdAt, let second = two.createdAt
                {
                    return first < second
                }
                return false
            }
            self.sections.append(CardSection(items: sorted, title: "Recent"))
        }
        completion()
    }
}
