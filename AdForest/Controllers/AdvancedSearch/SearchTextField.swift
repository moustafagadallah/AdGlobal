//
//  SearchTextField.swift
//  AdForest
//
//  Created by Apple on 9/17/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit


class SearchTextField: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var txtType: UITextField!
    
    var fieldName = ""
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        if UserDefaults.standard.bool(forKey: "isRtl") {
            txtType.textAlignment = .right
        } else {
            txtType.textAlignment = .left
        }
    }
}
