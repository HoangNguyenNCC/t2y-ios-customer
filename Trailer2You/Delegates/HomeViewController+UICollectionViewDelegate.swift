//
//  HomeViewController+UICollectionViewDelegate.swift
//  Trailer2You
//
//  Created by Aritro Paul on 10/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuredTrailers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedCollectionViewCell
        
        
        let processor = DownsamplingImageProcessor(size: cell.trailerImageView.bounds.size) |> RoundCornerImageProcessor(cornerRadius: 25)
        
        let url = URL(string: featuredTrailers[indexPath.row].photos?.first?.data ?? "")
        
        cell.trailerImageView.kf.indicatorType = .activity

        
        cell.trailerImageView.kf.setImage(
                  with: url,
              placeholder: UIImage(named: "placeholderImage"),
              options: [
                  .processor(processor),
                  .scaleFactor(UIScreen.main.scale),
                  .transition(.fade(1)),
                  .cacheOriginalImage
              ])
                
        cell.trailerNameLabel.text = featuredTrailers[indexPath.row].name
        cell.trailerPricingLabel.text = featuredTrailers[indexPath.item].type ?? ""
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedTrailer = featuredTrailers[indexPath.row]
        self.performSegue(withIdentifier: "feature", sender: featuredTrailers[indexPath.row])
    }
}
