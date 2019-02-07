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
    
    var id = ""
    
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
        cell.buttonRadio.imageView?.image = cell.buttonRadio.imageView?.image!.withRenderingMode(.alwaysTemplate)
        cell.buttonRadio.tintColor = UIColor(hex: objData.id)
        cell.buttonRadio.titleLabel?.text = cell.id     //objData.id
        cell.dataArray = dataArray
        id = cell.id
        cell.initializeData(value: objData, radioButtonCellRef: self, index: indexPath.row)
        
        return cell
        
    }
    
}

