//
//  RadioButtonTableViewCell.swift
//  AdForest
//
//  Created by Apple on 9/17/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class RadioButtonTableViewCell : UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var buttonRadio: UIButton!
    
    // var dataArray = [SearchValue]()
    var data : SearchValue?
    var radioButtonCell: RadioButtonCell!
    var indexPath = 0
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func initializeData(value: SearchValue, radioButtonCellRef: RadioButtonCell, index: Int) {
        data = value
        indexPath = index
        radioButtonCell = radioButtonCellRef
        buttonRadio.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
    }
    
    func initCellItem() {
        let deselectedImage = UIImage(named: "uncheck")?.withRenderingMode(.alwaysTemplate)
        let selectedImage = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate)
        buttonRadio.setImage(deselectedImage, for: .normal)
        buttonRadio.setImage(selectedImage, for: .selected)
        buttonRadio.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
    }
    
    @objc func radioButtonTapped(_ radioButton: UIButton) {
        if (radioButtonCell.dataArray[indexPath].isSelected) {
            buttonRadio.setBackgroundImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            
            //  data?.isSelected = false
            radioButtonCell.dataArray[indexPath].isSelected = false
            
        }
        else {
            buttonRadio.setBackgroundImage(#imageLiteral(resourceName: "check"), for: .normal)
            // data?.isSelected = true
            radioButtonCell.dataArray[indexPath].isSelected = true
        }
        
        for (i, value) in radioButtonCell.dataArray.enumerated() {
            if i != indexPath {
                radioButtonCell.dataArray[i].isSelected = false
            }
        }
        radioButtonCell.tableView.reloadData()
    }
    
    func deselectOtherButton() {
        let tableView = self.superview?.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        let section = tappedCellIndexPath.section
        let rowCounts = tableView.numberOfRows(inSection: section)
        
        for row in 0..<rowCounts {
            if row != tappedCellIndexPath.row {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as! RadioButtonTableViewCell
                cell.buttonRadio.isSelected = false
            }
        }
    }
}
