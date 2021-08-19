//
//  HomeViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 10/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import Motion

class HomeViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var featuredCollectionView: UICollectionView!
    
    
    /// Model for `Featured Trailers`
    var featuredTrailers = [FeaturedTrailer]()
    
    
    /// Selected Featured trailer
    var selectedTrailer = FeaturedTrailer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        /// set delegates
        featuredCollectionView.delegate = self
        featuredCollectionView.dataSource = self
        searchBarTextField.delegate = self
        
        /// initial setup
        searchBarModifications()
        tabBarModifications()
        getFeaturedTrailers()
        
        self.selectedTrailer = FeaturedTrailer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getPendingRatings()
    }
    
    fileprivate func getPendingRatings() {
        ServiceController.shared.getPendingRentals { (invoices) in
            guard invoices.count > 0 else { return }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "newrating", sender: invoices)
            }
        }
    }
    
    
    func getFeaturedTrailers(){
        ServiceController.shared.getfeaturedTrailers { (status, trailers, err) in
            DispatchQueue.main.async {
                if status {
                    self.featuredTrailers = trailers
                    self.featuredCollectionView.reloadData()
                }
            }
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func tabBarModifications() {
        self.tabBarController?.tabBar.makeCard()
        self.tabBarController?.cleanTitles()
    }
    
    func searchBarModifications() {
        searchBarContainer.makeCard()
        searchBarContainer.layer.cornerRadius = 8
        searchBarTextField.addIcon(iconName: "magnifyingglass")
        searchBarTextField.inputView = UIView()
        searchBarContainer.motionIdentifier = "container"
    }
    
    
    //MARK: ----- Navigation ------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addressVC = segue.destination as? AddressViewController {
            addressVC.view.backgroundColor = .white
            if let name = self.selectedTrailer.name {
                addressVC.selectedtrailer = name
            }
        }
        if let detailVC = segue.destination as? BookedTrailerDetailsViewController {
            detailVC.delegateF = self
            let trailer = TrailerDetailObject(features: selectedTrailer.features, photos: selectedTrailer.photos, availability: false, id: nil, name: selectedTrailer.name, type: selectedTrailer.type, description: selectedTrailer.description, size: selectedTrailer.size, capacity: selectedTrailer.capacity, age: 0, tare: selectedTrailer.tare, licenseeId: nil, rating: nil, rentalCharges: RentalCharges(pickUp: [], door2Door: []), price: nil, rentalsList: nil)
            detailVC.type = .featured
            detailVC.trailer = trailer
        }
        DispatchQueue.main.async {
            self.navigationController?.modalPresentationStyle = .fullScreen
        }
        if let reminderVC = segue.destination as? NotificationsViewController{
            reminderVC.reminderType = .rating
            reminderVC.invoices = sender as! [ReviewData]
            reminderVC.isRating = true
            DispatchQueue.main.async {
                reminderVC.modalPresentationStyle = .popover
            }
        }
    }
}

extension HomeViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchBarTextField {
            self.selectedTrailer = FeaturedTrailer()
            self.performSegue(withIdentifier: "search", sender: Any?.self)
            textField.resignFirstResponder()
        }
    }
}


extension HomeViewController : FeaturedDelegate {
    func didGetTrailerDetails(book: Bool) {
        self.performSegue(withIdentifier: "search", sender: nil)
    }
}
