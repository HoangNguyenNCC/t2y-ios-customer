//
//  BookedTrailerDetailsViewController.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 15/06/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import ProgressHUD
import Kingfisher

protocol bookedTrailerDelegate: class {
    func didGetTrailerDetails(trailer: TrailerDetailObject)
}

protocol FeaturedDelegate: class {
    func didGetTrailerDetails(book: Bool)
}


class BookedTrailerDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var trailerImage: UIImageView!
    @IBOutlet weak var ratingsView: UIStackView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var trailerDescriptionText: UITextView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var trailerName: UILabel!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var insurance: UILabel!
    @IBOutlet weak var servicing: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var capacity: UILabel!
    @IBOutlet weak var tare: UILabel!
    
    @IBOutlet weak var servicingRow: UIStackView!
    @IBOutlet weak var insuranceRow: UIStackView!
    
    @IBOutlet weak var ageRow: UIStackView!
    @IBOutlet weak var bookButton: UIButton!
    
    @IBOutlet weak var bottomStack: UIStackView!
    
    
    /// VARIABLES
    var booking : String?
    var trailer : TrailerDetailObject?
    var type : TrailersList = .all
    var name = ""
    
    weak var delegate: bookedTrailerDelegate?
    
    weak var delegateF : FeaturedDelegate?
    
    
    /// VIEW LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        initialSetup()
        
        if type == .featured{
            header.text = "FEATURED TRAILER"
            featureSetup()
        } else {
            bookButton.isHidden = true
            let headerText = (type == .licensee) ? (name + " Trailer") : "UPCOMING BOOKING"
            header.text = headerText
            (self.trailer != nil) ? self.setTrailerDetail(trailer!) : getTrailerDetails()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if trailer == nil{
            ProgressHUD.show("Loading Details", interaction: true)
            ProgressHUD.animationType = .singleCirclePulse
            ProgressHUD.colorAnimation = .primary
        }
    }
    
    @IBAction func bookTapped(_ sender: Any) {
        self.dismiss(animated: true){
            self.delegateF?.didGetTrailerDetails(book: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addressVc = segue.destination as? AddressViewController {
            addressVc.selectedtrailer = sender as? String
        }
    }
    
    
    
    func featureSetup(){
        ageRow.isHidden = true
        servicingRow.isHidden = true
        insuranceRow.isHidden = true
        ratingsView.isHidden = true
        ratingLabel.isHidden = true
        
        let processor = DownsamplingImageProcessor(size: trailerImage.bounds.size) |> RoundCornerImageProcessor(cornerRadius: 20)
        
        /// `textView` Setup
        trailerDescriptionText.text = trailer?.description ?? ""
        
        size.text = trailer?.size ?? ""
        capacity.text = trailer?.capacity?.formattedValue
        tare.text = trailer?.tare?.formattedValue
        
        
        
        trailerName.text = trailer?.name ?? "Trailer"
        
        /// `imageView` Setup
        guard let photo = trailer?.photos?.first else { return }
        trailerImage.kf.setImage(
            with: URL(string: photo?.data ?? ""),
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
        ])
    }
    
    
    
    
    func initialSetup(){
        
        photoCollection.delegate = self
        photoCollection.dataSource = self
        
        for star in ratingsView.subviews {
            star.tintColor = .systemGray5
        }
        trailerDescriptionText.text = ""
        bottomStack.alpha = 0.0
        ratingsView.alpha = 0.0
        ratingLabel.alpha = 0.0
    }
    
    func getTrailerDetails() {
        ServiceController.shared.getTrailerDetails(withId: booking) { (success, trailerObject, error) in
            if success {
                DispatchQueue.main.async {
                    if let trailer = trailerObject.trailerObj{
                        ProgressHUD.dismiss()
                        self.delegate?.didGetTrailerDetails(trailer: trailer)
                        self.trailer = trailer
                        self.setTrailerDetail(trailer)
                    }
                    self.photoCollection.reloadData()
                }
            } else {
                ProgressHUD.dismiss()
                print(error)
            }
        }
    }
    
    func setTrailerDetail(_ T : TrailerDetailObject) {
        let processor = DownsamplingImageProcessor(size: trailerImage.bounds.size) |> RoundCornerImageProcessor(cornerRadius: 8)
        
        bottomStack.alpha = 1.0
        ratingsView.alpha = 1.0
        ratingLabel.alpha = 1.0
        
        
        /// `textView` Setup
        trailerDescriptionText.text = T.description
        
        size.text = T.size ?? ""
        age.text = "\(T.age) years"
        capacity.text = T.capacity?.formattedValue
        tare.text = T.tare?.formattedValue
        
        /// `ratingStack` Setup
        if let stars = T.rating {
            if stars>0{
                for star in 0...(stars-1){
                    ratingsView.subviews[star].tintColor = .orange
                }
            } else {
                ratingLabel.isHidden = true
            }
            ratingLabel.text = "\(stars).0/5"
        }
        
        self.insurance.text = (T.insured ?? false) ? "✅" : "❌"
        
        self.servicing.text = (T.serviced ?? false) ? "✅" : "❌"
        
        trailerName.text = T.name ?? "Trailer"
        
        /// `imageView` Setup
        guard let photo = T.photos?.first else { return }
        trailerImage.kf.setImage(
            with: URL(string: photo?.data ?? ""),
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
        ])
    }
}

//MARK:- UICollectionView DataSource + Delegate Methods
extension BookedTrailerDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trailer?.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollection.dequeueReusableCell(withReuseIdentifier: "bookedtrailer", for: indexPath) as! BookedTrailerDetailsPhotoCollectionViewCell
        if let urlString = trailer?.photos?[indexPath.row]?.data, let url = URL(string: urlString){
            let processor = DownsamplingImageProcessor(size: cell.trailerPhoto.bounds.size) |>
                RoundCornerImageProcessor(cornerRadius: 5)
            cell.trailerPhoto.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholderImage"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BookedTrailerDetailsPhotoCollectionViewCell
        trailerImage.image = cell.trailerPhoto.image
    }
    
}


