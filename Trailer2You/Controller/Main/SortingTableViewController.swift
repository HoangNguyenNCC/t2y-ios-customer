//
//  SortingTableViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 22/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

protocol SortingDelegate {
    func didReturnSorting(sort: Sort, index: [Int],sortSettings:[Bool])
}

class SortingTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let priceSort = ["Low to High", "High to Low"]
    let distanceSort = ["Nearest First", "Furthest First"]
    let ratingSort = ["5 stars", "4 stars and above", "3 stars and above"]
    let bottomBar : CustomBottomBar = .fromNib()
    var selectedSort = Sort()
    var index = [Int]()
    var delegate: SortingDelegate?
    
    var sectionsareCollapsed : [Bool] = [true,true,true]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBarContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        addBottomBar()
    }
    
    func addBottomBar() {
        self.bottomBarContainer.addSubview(bottomBar)
        bottomBar.frame = bottomBarContainer.bounds
    }
    
    override func viewDidLayoutSubviews() {
        bottomBar.makeCard()
        bottomBar.showButton.layer.cornerRadius = bottomBar.showButton.frame.height/2
        bottomBar.showButton.setTitle("Sort", for: .normal)
        bottomBar.showButton.addTarget(self, action: #selector(sort), for: .touchUpInside)
        bottomBar.clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        bottomBar.layoutSubviews()
    }
    
    @objc func sort() {
        delegate?.didReturnSorting(sort: selectedSort, index: index, sortSettings: sectionsareCollapsed)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func clear() {
        index = [Int]()
        selectedSort = Sort()
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return sectionsareCollapsed[section] ? 0 : 3
        } else {
            return sectionsareCollapsed[section] ? 0 : 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sortCell", for: indexPath) as! FilterItemTableViewCell
        if indexPath.section == 0 {
            cell.itemName.text = priceSort[indexPath.row]
        }
        if indexPath.section == 1 {
            cell.itemName.text = distanceSort[indexPath.row]
        }
        if indexPath.section == 2 {
            cell.itemName.text = ratingSort[indexPath.row]
        }
        
        cell.isChecked = false
        cell.reset()
        
        if index.count > 0 {
            if indexPath.section == index[1] {
                if indexPath.row == index[0] {
                    cell.isChecked = true
                    cell.reuse()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTapped(indexPath: indexPath)
        index = [indexPath.row, indexPath.section]
        tableView.reloadSections(IndexSet(integersIn: 0...2), with: .automatic)
    }
    
    func cellTapped(indexPath : IndexPath){
        if indexPath.section == 0 {
               selectedSort.crit = .pricing
               switch indexPath.row {
               case 0: selectedSort.type = .ascending
               case 1: selectedSort.type = .descending
               default:
                   selectedSort.type = .ascending
               }
           }
           else if indexPath.section == 1 {
               selectedSort.crit = .distance
               switch indexPath.row {
               case 0: selectedSort.type = .ascending
               case 1: selectedSort.type = .descending
               default:
                   selectedSort.type = .ascending
               }
           }
           else if indexPath.section == 2 {
               selectedSort.crit = .rating
               switch indexPath.row {
               case 0: selectedSort.type = .five
               case 1: selectedSort.type = .fourPlus
               case 2: selectedSort.type = .threePlus
               default:
                   selectedSort.type = .five
               }
           }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView : FilterSectionHeader = .fromNib()
        headerView.collapseButton.addTarget(self, action: #selector(handleCollapse), for: .touchUpInside)
        headerView.collapseButton.tag = section
        let image = sectionsareCollapsed[section] ? UIImage(systemName: "arrowtriangle.down.fill") : UIImage(systemName: "arrowtriangle.up.fill")
        headerView.collapseButton.setBackgroundImage(image, for: .normal)
        if section == 0 {
            headerView.title.text = "Prices"
            headerView.subtitle.text = "Sort by pricing"
        }
        if section == 1 {
            headerView.title.text = "Distance"
            headerView.subtitle.text = "Sort by distance"

        }
        if section == 2 {
            headerView.title.text = "Rating"
            headerView.subtitle.text = "Sort by trailer ratings"
        }
        return headerView
    }
    
    @objc func handleCollapse(button : UIButton){
        sectionsareCollapsed[button.tag].toggle()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView : FilterSectionFooter = .fromNib()
        return footerView
    }
}
