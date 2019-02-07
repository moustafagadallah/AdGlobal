//
//  PackagesCell.swift
//  AdForest
//
//  Created by Apple on 7/20/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import DropDown

class PackagesCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    
    @IBOutlet weak var lblOfferName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var lblValidity: UILabel!
    @IBOutlet weak var lblFreeAds: UILabel!
    @IBOutlet weak var lblFeaturedAds: UILabel!
    @IBOutlet weak var lblBumpUpAds: UILabel!
    @IBOutlet weak var viewButton: UIView! {
        didSet {
            viewButton.layer.borderWidth = 0.5
            viewButton.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var buttonSelectOption: UIButton! {
        didSet {
            buttonSelectOption.contentHorizontalAlignment = .left
        }
    }
    
    //MARK:- Properties
    var delegate : PaymentTypeDelegate?
    let categoryDropDown = DropDown()
    
    lazy var dropDown : [DropDown] = {
        return [
            self.categoryDropDown
        ]
    }()
    
    var dropShow: (()->())?
    var dropDownValueArray = [String]()
    var dropDownKeyArray = [String]()
    
    
    var defaults = UserDefaults.standard
    var settingObject = [String: Any]()
    var popUpMsg = ""
    var popUpText = ""
    var popUpCancelButton = ""
    var popUpOkButton = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedInAppPackage = ""
    
    var package_id = ""
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.adForest_settingsData()
        buttonWithRtl()
    }
    
    //MARK:- Custom
    
    func buttonWithRtl(){
        if UserDefaults.standard.bool(forKey: "isRtl") {
            buttonSelectOption.contentHorizontalAlignment = .right
        } else {
            buttonSelectOption.contentHorizontalAlignment = .left
        }
    }
    
    func selectCategory() {
        categoryDropDown.anchorView = buttonSelectOption
        categoryDropDown.dataSource = dropDownValueArray
        categoryDropDown.selectionAction = { [unowned self] (index, item) in
            self.buttonSelectOption.setTitle(item, for: .normal)
            let cashTypeKey = self.dropDownKeyArray[index]
            //send data to main class to send to server in alert controller action
            let alert = UIAlertController(title: self.popUpMsg, message: self.popUpText, preferredStyle: .alert)
            let okAction = UIAlertAction(title: self.popUpOkButton, style: .default, handler: { (okAction) in
                self.delegate?.paymentMethod(methodName: cashTypeKey, inAppID: self.selectedInAppPackage, packageID: self.package_id)
            })
            let cancelAction = UIAlertAction(title: self.popUpCancelButton, style: .default, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.appDelegate.presentController(ShowVC: alert)
        }
    }
    
    func adForest_settingsData() {
        if let settingsInfo = defaults.object(forKey: "settings") {
            settingObject = NSKeyedUnarchiver.unarchiveObject(with: settingsInfo as! Data) as! [String : Any]
            
            let model = SettingsRoot(fromDictionary: settingObject)
            
            if let dialogMSg = model.data.dialog.confirmation.title {
                self.popUpMsg = dialogMSg
            }
            if let dialogText = model.data.dialog.confirmation.text {
                self.popUpText = dialogText
            }
            if let cancelText = model.data.dialog.confirmation.btnNo {
                self.popUpCancelButton = cancelText
            }
            if let confirmText = model.data.dialog.confirmation.btnOk {
                self.popUpOkButton = confirmText
            }
        }
    }
    
    //MARK:- IBActions
    @IBAction func actionSelectOption(_ sender: Any) {
        dropShow?()
    }
}

