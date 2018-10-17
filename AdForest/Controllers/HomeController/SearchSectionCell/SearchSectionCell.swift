//
//  SearchSectionCell.swift
//  AdForest
//
//  Created by Apple on 8/27/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class SearchSectionCell: UITableViewCell {

    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var oltSearch: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var containerViewtextField: UIView! {
        didSet {
            containerViewtextField.roundCorners()
        }
    }
    @IBOutlet weak var containerViewSearch: UIView! {
        didSet {
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor") {
                containerViewSearch.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var lineView: UIView! {
        didSet {
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor") {
                lineView.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    
    //MARK:- Properties
    var btnSearchAction : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        if UserDefaults.standard.bool(forKey: "isRtl") {
            txtSearch.textAlignment = .right
        } else {
            txtSearch.textAlignment = .left
        }
        
        
    }

    @IBAction func actionSearch(_ sender: Any) {
        btnSearchAction?()
    }
}
