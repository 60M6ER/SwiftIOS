//
//  CustomViewCell.swift
//  MyViewCollectionApp
//
//  Created by Борис Ларионов on 25.03.2026.
//

import UIKit

class CustomViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textOne: UILabel!
    @IBOutlet weak var textTwo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
