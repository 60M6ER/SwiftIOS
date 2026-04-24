//
//  Cell.swift
//  WatherApp
//
//  Created by Борис Ларионов on 26.03.2026.
//

import UIKit

class Cell: UICollectionViewCell {
    
    @IBOutlet weak var temperatureImage: UIImageView!
    @IBOutlet weak var smileImage: UIImageView!
    
    func setTemperatureImage(tempName: String) {
        temperatureImage.image = UIImage(named: tempName)
    }
    
    func setSmileImage(smileName: String) {
        smileImage.image = UIImage(named: smileName)
      }
}
