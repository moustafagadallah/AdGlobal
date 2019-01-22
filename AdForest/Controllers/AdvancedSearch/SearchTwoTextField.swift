//
//  SearchTwoTextField.swift
//  AdForest
//
//  Created by Apple on 9/17/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class SearchTwoTextField: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var txtMinPrice: UITextField!
    @IBOutlet weak var txtmaxPrice: UITextField!
    @IBOutlet weak var lblMin: UILabel!
    
    //MARK:- Properties
    
    var fieldName = ""
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
    }
}
