//
//  CalendarCell.swift
//  AdForest
//
//  Created by Apple on 8/29/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class CalendarCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var oltDate: UIButton! {
        didSet {
            oltDate.contentHorizontalAlignment = .left
        }
    }
    
    //MARK:- Properties
    var currentDate = ""
    var fieldName = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBAction func actionCalendar(_ sender: Any) {
        let datePicker = ActionSheetDatePicker(title: "", datePickerMode: UIDatePickerMode.date, selectedDate: Date(), doneBlock: {
            picker, value, index in
            print("value = \(value!)")
            print("index = \(index!)")
            print("picker = \(picker!)")
           
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let selectedDate = dateFormatter.string(from: value as! Date)
            self.oltDate.setTitle(selectedDate, for: .normal)
            self.currentDate = selectedDate
            
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender as! UIView)
        datePicker?.show()
    }
    
}
