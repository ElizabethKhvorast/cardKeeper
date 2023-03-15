//
//  CardViewController.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 15/03/2023.
//

import UIKit

protocol CardViewControllerDelegate: AnyObject
{
    func cardWasUpdated()
}

class CardViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    weak var delegate: CardViewControllerDelegate?
    var cardItem: CardItem?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.imageView.image = self.cardItem?.image
        self.textView.text = self.cardItem?.title
        self.favoriteButton.image = self.cardItem?.isFavorite == true ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
    }
    
    private func removeCard()
    {
        if let barcode = self.cardItem?.barcode, let entity = CardEntity.getItemBy(barcode)
        {
            DataManager.shared.managedObjectContext.delete(entity)
            DataManager.shared.saveMain()
            self.delegate?.cardWasUpdated()
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    private func saveCard()
    {
        self.cardItem?.title = self.textView.text
        self.cardItem?.save()
        self.delegate?.cardWasUpdated()
    }
    
    @IBAction func optionsPressed(_ sender: Any)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.removeCard()
        }))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            self?.saveCard()
        }))
        self.present(alertController, animated: true)
    }
    
    @IBAction func favoritePressed(_ sender: Any)
    {
        let current = self.cardItem?.isFavorite ?? false
        self.cardItem?.isFavorite = !current
        self.cardItem?.save()
        self.favoriteButton.image = self.cardItem?.isFavorite == true ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.delegate?.cardWasUpdated()
    }
    
    @IBAction func closePressed(_ sender: Any)
    {
        self.navigationController?.dismiss(animated: true)
    }
}

extension CardViewController: UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
