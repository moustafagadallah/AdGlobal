//
//  TextFieldCell.swift
//  AdForest
//
//  Created by apple on 5/9/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

protocol AddDataDelegate {
    func addToFieldsArray(obj: AdPostField, index: Int, isFrom: String, title: String)
}

protocol textValDelegate {
    func textVal(value: String,indexPath: Int, fieldType:String, section: Int)
}

class TextFieldCell: UITableViewCell, UITextFieldDelegate {

    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var txtType: UITextField!{
        didSet{
            txtType.delegate = self
        }
    }
    
    //MARK:- Properties
    //var delegate: AddDataDelegate?
    var fieldName = ""
    var objSaved = AdPostField()
    var selectedIndex = 0
    //var delegate : textFieldValueDelegate?
    var index = 0
    var section = 0
    var delegate : textValDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        objSaved.fieldVal = txtType.text
       // self.delegate?.addToFieldsArray(obj: objSaved, index: selectedIndex, isFrom: "textfield", title: "")
    }
    
    @IBAction func txtEditingChanged(_ sender: UITextField) {
        if let text = sender.text {
            //delegate?.changeText(value: text, fieldTitle: fieldName)
            delegate?.textVal(value: text, indexPath: index,fieldType: "textfield",section:section)
        }
    }
}
