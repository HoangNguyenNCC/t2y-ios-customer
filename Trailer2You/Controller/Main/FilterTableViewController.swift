//
//  FilterTableViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 22/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

protocol FilterDelegate : class {
    func didAddFilters(filters : [FilterItems], delivery: DeliveryMethod,filterSettings : [Bool])
    
}

class FilterTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DeliveryDelegate {

    var filters = Filters()
    @IBOutlet weak var bottomBarContainer: UIView!
    let bottomBar : CustomBottomBar = .fromNib()
    var typeFilters = [FilterItems]()
    var modelFilters = [FilterItems]()
    var itemFilters = [FilterItems]()
    var filterItems = [FilterItems]()
    weak var delegate: FilterDelegate?
    var deliveryMethod : DeliveryMethod = .pickup
    @IBOutlet weak var tableView: UITableView!
    

    var sectionsareCollapsed : [Bool] = [true,true,true]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        resetFilters()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func resetFilters() {
         typeFilters = filterItems.filter({ (filter) -> Bool in
            return (filters.trailerTypesList?.contains(where: { (trailerTypes) -> Bool in
                return trailerTypes.code == filter.code
            }) ?? false)
         })
        itemFilters = filterItems.filter({ (filter) -> Bool in
            return (filters.upsellItemTypesList?.contains(where: { (itemTypes) -> Bool in
                return itemTypes.code == filter.code
            }) ?? false)
        })
        print("MODELFILTER",modelFilters)
        modelFilters = filterItems.filter({ (filter) -> Bool in
            return (filters.trailerModelList?.contains(where: { (itemTypes) -> Bool in
                return itemTypes.code == filter.code
            }) ?? false)
        })
    }
    
    func addBottomBar() {
        
        self.bottomBarContainer.addSubview(bottomBar)
        self.bottomBar.frame = bottomBarContainer.bounds
    }
    
    override func viewDidLayoutSubviews() {
        addBottomBar()
        bottomBar.makeCard()
        self.view.bringSubviewToFront(bottomBar)
        bottomBar.showButton.layer.cornerRadius = bottomBar.showButton.frame.height/2
        bottomBar.showButton.setTitle("Filter", for: .normal)
        bottomBar.showButton.addTarget(self, action: #selector(filter), for: .touchUpInside)
        bottomBar.clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        bottomBar.layoutSubviews()
    }

    func didSetDelivery(method: DeliveryMethod) {
        self.deliveryMethod = method
    }
    
    @objc func filter() {
        filterItems = typeFilters + itemFilters + modelFilters
        delegate?.didAddFilters(filters: filterItems, delivery: deliveryMethod, filterSettings: sectionsareCollapsed)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func clear() {
        typeFilters.removeAll()
        modelFilters.removeAll()
        itemFilters.removeAll()
        tableView.reloadData()
        tableView.reloadData()
    }
    
    
    @IBAction func exitTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            //
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sectionsareCollapsed[section] ? 0 : filters.trailerTypesList?.count ?? 0
        }
        else if section == 1{
            return sectionsareCollapsed[section] ? 0 : filters.trailerModelList?.count ?? 0
        }
        else if section == 2{
            return sectionsareCollapsed[section] ? 0 : filters.upsellItemTypesList?.count ?? 0
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! FilterItemTableViewCell
        cell.checkButton.addTarget(self, action: #selector(filterTapped(sender:)), for: .touchUpInside)
        cell.checkButton.tag = (indexPath.section*10)+(indexPath.row)
            if indexPath.section == 0 {
                let typeItem = filters.trailerTypesList?[indexPath.row]
                
                cell.itemName.text = typeItem?.name
                if typeFilters.contains(where: { (item) -> Bool in
                    return item.code == typeItem?.code
                }) {
                    cell.isChecked = false
                    cell.check()
                }
                else {
                    cell.isChecked = false
                    cell.reuse()
                }
                
            } else if indexPath.section == 1{
               let typeItem = filters.trailerModelList?[indexPath.row]
               
               cell.itemName.text = typeItem?.name
                
               if modelFilters.contains(where: { (item) -> Bool in
                   return item.code == typeItem?.code
               }) {
                   cell.isChecked = false
                   cell.check()
               }
               else {
                   cell.isChecked = false
                   cell.reuse()
               }
            }
            else if indexPath.section == 2 {
               let upsellItem = filters.upsellItemTypesList?[indexPath.row]
                cell.itemName.text = upsellItem?.name

                if itemFilters.contains(where: { (item) -> Bool in
                    return item.code == upsellItem?.code
                }) {
                    cell.isChecked = false
                    cell.check()
                }
                else {
                    cell.isChecked = false
                    cell.reuse()
                }
            }
            return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 2 {
            let cell = tableView.cellForRow(at: indexPath) as! FilterItemTableViewCell
            self.cellTapped(cell: cell, indexPath: indexPath)
        }
        else {
           // let cell = tableView.cellForRow(at: indexPath) as! FilterDeliveryTableViewCell
        }
    }
    
    func cellTapped(cell : FilterItemTableViewCell,indexPath : IndexPath){
        if indexPath.section == 0 {
                let selectedItem = filters.trailerTypesList?[indexPath.row]
                if typeFilters.contains(where: { (item) -> Bool in
                    return item.code == selectedItem?.code
                }) {
                    typeFilters = typeFilters.filter { $0.code != selectedItem?.code }
                    filterItems = filterItems.filter { $0.code != selectedItem?.code }
                }
                else {
                    typeFilters.append(selectedItem!)
                }
            } else if indexPath.section == 1{
                let selectedItem = filters.trailerModelList?[indexPath.row]
                if modelFilters.contains(where: { (item) -> Bool in
                    return item.code == selectedItem?.code
                }) {
                    modelFilters = modelFilters.filter { $0.code != selectedItem?.code }
                    filterItems = filterItems.filter { $0.code != selectedItem?.code }
                }
                else {
                    modelFilters.append(selectedItem!)
                }
            }
            else if indexPath.section == 2{
                let selectedItem = filters.upsellItemTypesList?[indexPath.row]
                if itemFilters.contains(where: { (item) -> Bool in
                    return item.code == selectedItem?.code
                }) {
                    itemFilters = itemFilters.filter { $0.code != selectedItem?.code }
                    filterItems = filterItems.filter { $0.code != selectedItem?.code }
                }
                else {
                    itemFilters.append(selectedItem!)
                }
            }
            cell.check()
    }
    
    @objc
    func filterTapped(sender : UIButton){
        let tag = sender.tag
        let row = tag%10
        let index = tag/10
        let indexPath = IndexPath(row: row, section: index)
        let cell = tableView.cellForRow(at: indexPath) as! FilterItemTableViewCell
        cellTapped(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView : FilterSectionHeader = .fromNib()
        headerView.collapseButton.addTarget(self, action: #selector(handleCollapse), for: .touchUpInside)
        headerView.collapseButton.tag = section
        let image = sectionsareCollapsed[section] ? UIImage(systemName: "arrowtriangle.down.fill") : UIImage(systemName: "arrowtriangle.up.fill")
        headerView.collapseButton.setBackgroundImage(image, for: .normal)
        
        switch section {
        case 0:
            headerView.title.text = "Trailer Type"
            headerView.subtitle.text = "Type of the trailer"
        case 1:
            headerView.title.text = "Trailer Model"
            headerView.subtitle.text = "Model of the trailer"
        case 2:
            headerView.title.text = "Upsell Items"
            headerView.subtitle.text = "Choose items to go with the trailer"
        default:
            print("NO")
        }
        
        return headerView
    }
    
    @objc func handleCollapse(button : UIButton){
         sectionsareCollapsed[button.tag].toggle()
         tableView.reloadData()
     }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView: FilterSectionFooter = .fromNib()
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
}
