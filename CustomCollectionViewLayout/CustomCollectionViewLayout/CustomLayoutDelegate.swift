//
//  CustomLayoutDelegate.swift
//  CustomCollectionViewLayout
//
//  Created by Борис Ларионов on 25.03.2026.
//

import UIKit

protocol CustomLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGSize
}
