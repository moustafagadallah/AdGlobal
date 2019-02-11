//
//  CheckBoxButtonCell.swift
//  AdForest
//
//  Created by Furqan Nadeem on 30/01/2019.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit

class CheckBoxButtonCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var lblTitle: UILabel!
    
    
    //MARK:- Properties
    var dataArray = [SearchValue]()
    var title = ""
    var fieldName = ""
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 //dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CheckBoxesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CheckBoxesTableViewCell", for: indexPath) as! CheckBoxesTableViewCell
        let objData = dataArray[indexPath.row]

        cell.title = title
        cell.dataArray = dataArray
        cell.initializeData(value: objData, radioButtonCellRef: self, index: indexPath.row)
        //cell.initCellItem()
        return cell
    }

}

