//
//  CardCollectionViewCell.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 13/03/2023.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.clear()
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.clear()
    }
    
    private func clear()
    {
        self.imageView.image = nil
        self.descriptionLabel.text = nil
    }

}
