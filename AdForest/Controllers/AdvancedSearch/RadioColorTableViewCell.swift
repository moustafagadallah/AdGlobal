//
//  RadioColorTableViewCell.swift
//  AdForest
//
//  Created by Furqan Nadeem on 31/01/2019.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit

class RadioColorTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK:- Outlets
    
   
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.addShadowToView()
        }
    }
   
    
    @IBOutlet weak var lblTitle: UILabel!
    
    
    //MARK:- Properties
    var dataArray = [SearchValue]()
    var title = ""
    var id = ""
    var fieldName = ""
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: RadioColorCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RadioColorCollectionViewCell", for: indexPath) as! RadioColorCollectionViewCell
        
        let objData = dataArray[indexPath.row]
        //cell.buttonRadio.
        //cell.imgViewRadio.image = cell.imgViewRadio.image!.withRenderingMode(.alwaysTemplate)
        //cell.buttonRadio.layer.borderColor = UIColor(hex: objData.id!).cgColor
        //cell.buttonRadio.titleLabel?.text = cell.id     //objData.id
        cell.dataArray = dataArray
        id = cell.id
        
        print(objData.id)
        cell.reloadInputViews()
        cell.initializeData(value: objData, radioButtonCellRef: self, index: indexPath.row)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! RadioColorCollectionViewCell
        
       let objData = dataArray[indexPath.row]
       cell.imgViewRadio.backgroundColor = UIColor(hex: objData.id)
       //cell.imgViewRadio.image = UIImage(named: "")
        //cell.containerView.backgroundColor = UIColor.orange
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as!
        RadioColorCollectionViewCell
        //let objData = dataArray[indexPath.row]
        cell.imgViewRadio.backgroundColor = UIColor.clear
        //let objData = dataArray[indexPath.row]
        //cell.imgViewRadio.backgroundColor = UIColor(hex: objData.id)
        //let objData = dataArray[indexPath.row]
       // cell.imgViewRadio.image = cell.imgViewRadio.image!.withRenderingMode(.alwaysTemplate)
        //cell.imgViewRadio.tintColor = UIColor.clear
      
      
    }
    
    
}

