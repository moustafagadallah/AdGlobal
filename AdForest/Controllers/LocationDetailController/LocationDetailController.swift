//
//  LocationDetailController.swift
//  AdForest
//
//  Created by Apple on 9/12/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LocationDetailController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable, UISearchBarDelegate {

    //MARK:- Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.placeholder = ""
            searchBar.delegate = self
            searchBar.sizeToFit()
        }
    }
    
    //MARK:- Properties
    var dataArray = [LocationDetailTerm]()
    var currentPage = 0
    var maximumPage = 0
    
    var filteredArray = [LocationDetailTerm]()
    var shouldShowSearchResults = false
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        let param: [String: Any] = ["term_name":"ad_country", "term_id": "", "page_number":1]
        print(param)
        self.adForest_locationDetails(parameter: param as NSDictionary)
    }
    
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    
    
    
    
    //MARK:- Collection View Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray.count
        } else {
            return dataArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LocationDetailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationDetailCell", for: indexPath) as! LocationDetailCell
        
        if shouldShowSearchResults {
            let objData = filteredArray[indexPath.row]
            if let imgUrl = URL(string: objData.termImg) {
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
            }
            if let name = objData.name {
                cell.lblName.text = name
            }
            if let count = objData.count {
                cell.lblAds.text = String(count)
            }
        } else {
            let objData = dataArray[indexPath.row]
            if let imgUrl = URL(string: objData.termImg) {
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
            }
            if let name = objData.name {
                cell.lblName.text = name
            }
            if let count = objData.count {
                cell.lblAds.text = String(count)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objData = dataArray[indexPath.row]
        if objData.hasChildren {
            let param: [String: Any] = ["term_name":"ad_country", "term_id": objData.termId, "page_number":1]
            print(param)
            self.adForest_locationDetails(parameter: param as NSDictionary)
        } else {
            let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
            categoryVC.categoryID = objData.termId
            categoryVC.isFromLocation = true
            self.navigationController?.pushViewController(categoryVC, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if Constants.isiPadDevice {
            let width = collectionView.bounds.width/3.0
            return CGSize(width: width, height: 140)
        }
        let width = collectionView.bounds.width/2.0
        return CGSize(width: width, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
        if indexPath.row == dataArray.count - 1 && currentPage < maximumPage {
            currentPage = currentPage + 1
            let param: [String: Any] = ["term_name":"ad_country", "term_id": "", "page_number": currentPage]
            print(param)
            self.adForest_loadMoreData(parameter: param as NSDictionary)
        }
    }
    
    //MARK:- API Calls
    
    func adForest_locationDetails(parameter: NSDictionary) {
        self.showLoader()
        AddsHandler.locationDetails(parameter: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.data.pageTitle
                self.currentPage = successResponse.data.pagination.currentPage
                self.maximumPage = successResponse.data.pagination.maxNumPages
                self.dataArray = successResponse.data.terms
                self.collectionView.reloadData()
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
    
    //LoadMore Data
    func adForest_loadMoreData(parameter: NSDictionary) {
        self.showLoader()
        AddsHandler.locationDetails(parameter: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.dataArray.append(contentsOf: successResponse.data.terms)
                self.collectionView.reloadData()
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
