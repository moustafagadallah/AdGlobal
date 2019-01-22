//
//  SellersController.swift
//  AdForest
//
//  Created by Apple on 9/6/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SellersController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {

    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    
    //MARK:- Properties
    var dataArray = [SellersAuthor]()
    let defaults = UserDefaults.standard
    var currentPage = 0
    var maximumPage = 0
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.bool(forKey: "isRtl") {
            self.addRightBarButtonWithImage(#imageLiteral(resourceName: "menu"))
        } else {
            self.addLeftBarButtonWithImage(#imageLiteral(resourceName: "menu"))
        }
        self.adForest_sellerData()
    }
    
    //MARK:- Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    //MARK:- Table View Delegates

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SellerCell = tableView.dequeueReusableCell(withIdentifier: "SellerCell", for: indexPath) as! SellerCell
        let objData = dataArray[indexPath.row]
        
        if let imgUrl = URL(string: objData.authorImg) {
            cell.imgProfile.sd_setShowActivityIndicatorView(true)
            cell.imgProfile.sd_setIndicatorStyle(.gray)
            cell.imgProfile.sd_setImage(with: imgUrl, completed: nil)
        }
        if let name = objData.authorName {
            cell.lblName.text = name
        }
        if let location = objData.authorAddress {
            cell.lblLocation.text = location
        }
        if let rating = objData.authorRating {
            cell.ratingBar.settings.updateOnTouch = false
            cell.ratingBar.rating = Double(rating)!
            cell.ratingBar.settings.filledColor = Constants.hexStringToUIColor(hex: Constants.AppColor.ratingColor)
        }
        cell.dataArray = objData.authorSocial.socialIcons
        cell.collectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let objData = dataArray[indexPath.row]
        let publicProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UserPublicProfile") as! UserPublicProfile
        publicProfileVC.userID = String(objData.authorId)
        self.navigationController?.pushViewController(publicProfileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
        if indexPath.row == dataArray.count && currentPage < maximumPage  {
            currentPage = currentPage + 1
            let param: [String: Any] = ["page_number": currentPage]
            adForest_loadMoreData(param: param as NSDictionary)
        }
    }

    //MARK:- API Call
    func adForest_sellerData() {
        self.showLoader()
        ShopHandler.sellerList(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.data.pageTitle
                self.currentPage = successResponse.data.pagination.currentPage
                self.maximumPage = successResponse.data.pagination.maxNumPages
                self.dataArray = successResponse.data.authors
                self.tableView.reloadData()
            } else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
            }
        }) { (error) in
            self.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }
    
    func adForest_loadMoreData(param: NSDictionary) {
        self.showLoader()
        ShopHandler.sellerListLoadMore(param: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.dataArray.append(contentsOf: successResponse.data.authors)
                self.tableView.reloadData()
            } else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
            }
        }) { (error) in
            self.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }
}
