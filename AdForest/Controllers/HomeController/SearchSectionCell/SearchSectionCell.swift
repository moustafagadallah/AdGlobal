//
//  SearchSectionCell.swift
//  AdForest
//
//  Created by Apple on 8/27/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class SearchSectionCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtSearch: UITextField!{
        didSet {
            txtSearch.delegate = self
        }
    }
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
    
    
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        if UserDefaults.standard.bool(forKey: "isRtl") {
            txtSearch.textAlignment = .right
            lblTitle.textAlignment = .right
            lblSubTitle.textAlignment = .right
        } else {
            txtSearch.textAlignment = .left
            lblTitle.textAlignment = .left
            lblSubTitle.textAlignment = .left
        }
    
    }
    
  
    
    
    //MARK:- TextField Deletage
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtSearch {
            txtSearch.resignFirstResponder()
            categoryDetail()
        }
        return true
    }
    
    //MARK:- Custom
    func categoryDetail() {
        guard let searchText = txtSearch.text else {return}
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let categoryVC = storyboard.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
        categoryVC.searchText = searchText
        categoryVC.isFromTextSearch = true
        self.viewController()?.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    //MARK:- IBActions
    @IBAction func actionSearch(_ sender: UIButton) {
        categoryDetail()
    }
}
