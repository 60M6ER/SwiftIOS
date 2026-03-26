//
//  MyCollectionViewController.swift
//  MyViewCollectionApp
//
//  Created by Борис Ларионов on 24.03.2026.
//

import UIKit

private let reuseIdentifier = "ItemCell"
private let customReuseNameFile = "CustomViewCell"
private let customReuseIdentifier = "CustomItemCell"

class MyCollectionViewController: UICollectionViewController {

    struct  StructItem {
      let image: String
      let text: String
    }
    
    
    struct StructCustomItem {
        let image:String
        let textOne:String
        let textTwo:String
    }
    
    var arrayItems = [StructItem]()
    var customItems = [StructCustomItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let xib = UINib(nibName: customReuseNameFile, bundle: nil)
            collectionView.register(xib, forCellWithReuseIdentifier: customReuseIdentifier)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        arrayItems.append(StructItem(image: "temp.darkYellow", text: "Dark yellow color"))
        arrayItems.append(StructItem(image: "temp.orange", text: "Orange color"))
        arrayItems.append(StructItem(image: "temp.red", text: "Red color"))
        
        customItems.append(StructCustomItem(image: "temp.lightYellow", textOne: "Light Yellow Color", textTwo: "item one"))
        customItems.append(StructCustomItem(image: "temp.orange", textOne: "Orange Color", textTwo: "item two"))
        customItems.append(StructCustomItem(image: "temp.red", textOne: "Red Color", textTwo: "item three"))
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
        return customItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customReuseIdentifier, for: indexPath) as? CustomViewCell {
            
            cell.imageView.image = UIImage(named: customItems[indexPath.row].image)
            cell.textOne.text = customItems[indexPath.row].textOne
            cell.textTwo.text = customItems[indexPath.row].textTwo
                  return cell
        }
        // Configure the cell
    
        return UICollectionViewCell()
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
