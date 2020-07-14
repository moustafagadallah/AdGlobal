//
//  LangCollectionViewCell.swift
//  AdForest
//
//  Created by Furqan Nadeem on 13/06/2019.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit

class LangCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var imgCountry: UIImageView!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var btnCode: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBg.addShadow()
        
    }
    
}
