//
//  CollectionViewController.swift
//  CustomCollectionViewLayout
//
//  Created by Борис Ларионов on 25.03.2026.
//

import UIKit

private let reuseIdentifier = "CollectionCell"

class CollectionViewController: UICollectionViewController {

    
    
    struct StructImage {
        let image: UIImage
    }
    
    var arrayImages = [StructImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let i1 = UIImage(named: "i1")!
        let i2 = UIImage(named: "i2")!
        let i3 = UIImage(named: "i3")!
        let i4 = UIImage(named: "i4")!
        let i5 = UIImage(named: "i5")!
        let i6 = UIImage(named: "i6")!

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        arrayImages.append(StructImage(image: i1))
        arrayImages.append(StructImage(image: i2))
        arrayImages.append(StructImage(image: i3))
        arrayImages.append(StructImage(image: i4))
        arrayImages.append(StructImage(image: i5))
        arrayImages.append(StructImage(image: i6))
        arrayImages.append(StructImage(image: i2))
        arrayImages.append(StructImage(image: i4))
        arrayImages.append(StructImage(image: i6))
        arrayImages.append(StructImage(image: i1))
        arrayImages.append(StructImage(image: i2))
        arrayImages.append(StructImage(image: i5))
        arrayImages.append(StructImage(image: i1))
        arrayImages.append(StructImage(image: i2))
        arrayImages.append(StructImage(image: i4))
        arrayImages.append(StructImage(image: i3))
        
        if let layout = collectionView?.collectionViewLayout as? CustomLayout {
                   layout.delegateLayout = self
            }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arrayImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomViewCell
        cell.image.image = arrayImages[indexPath.row].image
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension CollectionViewController: CustomLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath:IndexPath) -> CGSize {
    return arrayImages[indexPath.item].image.size
  }
}
