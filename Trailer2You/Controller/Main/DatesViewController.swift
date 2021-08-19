//
//  DatesViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 19/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SPAlert

protocol DatesDelegate : class {
    func returnDates(dates: [String])
}

class DatesViewController: UIViewController {
    
    /// Outlets
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var nextBttn: UIButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    
    /// Variables
    var booking = BookingModel()
    var address = ""
    var editRentalModel : EditRentalModel?
    var firstDate: Date?
    var secondDate: Date?
    var times: [String]?
    
    /// Selected Featured Trailer
    var selectedtrailer : String?
    
    weak var delegate : DatesDelegate?
    var presenter : UIViewController?
    var requestType : Int?
    
    var twoDatesAlreadySelected: Bool {
        return firstDate != nil && calendarView.selectedDates.count > 1
    }
    
    var months = 0
    var dates = [String]()
    let df = DateFormatter()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomBar.makeCard()
        
        if dates.count > 1 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            let fromDate = dateFormatter.date(from: dates[0])
            let toDate = dateFormatter.date(from: dates[1])
            calendarView.selectDates(from: fromDate!, to: toDate!)
        }
        else if dates.count > 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            let fromDate = dateFormatter.date(from: dates[0])
            calendarView.selectDates([fromDate!])
        }
        
        calendarView.scrollingMode   = .stopAtEachCalendarFrame
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
        overrideUserInterfaceStyle = .light
    }
    
    override func viewDidLayoutSubviews() {
        nextBttn.layer.cornerRadius = 8
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextBttnTapped(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, YYYY"
        
        if let firstDate = firstDate, let secondDate = secondDate {
            dates = [formatter.string(from: firstDate), formatter.string(from: secondDate)]
            if presenter?.isKind(of: TrailerViewController.self) ?? false {
                delegate?.returnDates(dates: dates)
                self.dismiss(animated: true, completion: nil)
            }
            else if presenter?.isKind(of: UpcomingBookingTableViewController.self) ?? false {
                if requestType == 0 {
                    //delegate?.returnDates(dates: dates)
                    //self.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "duration", sender: Any?.self)
                }
                else {
                    self.performSegue(withIdentifier: "duration", sender: Any?.self)
                }
            }
            else {
                self.performSegue(withIdentifier: "duration", sender: Any?.self)
            }
        } else {
            SPAlert.present(message: "Please choose your dates", haptic: .error)
        }
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
    }
    
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        cell.dateLabel.textColor = (cellState.dateBelongsTo == .thisMonth) ? .black : .secondaryLabel
    }
    
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        cell.selectedView.isHidden = !cellState.isSelected
        switch cellState.selectedPosition() {
        case .left:
            cell.selectedView.layer.cornerRadius = 24
            cell.selectedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        case .middle:
            cell.selectedView.layer.cornerRadius = 0
            cell.selectedView.layer.maskedCorners = []
        case .right:
            cell.selectedView.layer.cornerRadius = 24
            cell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        case .full:
            cell.selectedView.layer.cornerRadius = 24
            cell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        default: break
        }
        
        if cellState.isSelected {
            cell.dateLabel.textColor = UIColor.white
        }
    }
}

extension DatesViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.year = 1
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        return ConfigurationParameters(startDate: currentDate, endDate: futureDate!, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid, hasStrictBoundaries: false)
    }
}

extension DatesViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        df.dateFormat = "MMM YYYY"
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthTitle.text = df.string(from: range.start)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 80)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if firstDate != nil {
            secondDate = date
            calendar.selectDates(from: firstDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        } else {
            firstDate = date
            secondDate = date
        }
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if date < Date.today {
            return false
        }
        if calendarView.selectedDates.count > 0 {
            if twoDatesAlreadySelected && cellState.selectionType != .programatic || firstDate != nil && date < calendarView.selectedDates[0] {
                firstDate = nil
                let retval = !calendarView.selectedDates.contains(date)
                calendarView.deselectAllDates()
                return retval
            }
        }
        return true
    }
    
    

    

    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if twoDatesAlreadySelected && cellState.selectionType != .programatic {
            firstDate = nil
            secondDate = nil
            calendarView.deselectAllDates()
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let durationVC = segue.destination as? DurationViewController {
            booking.dates = dates
            durationVC.address = address
            durationVC.booking = booking
            if presenter != nil {
                durationVC.times = times!
                durationVC.presenter = presenter
                durationVC.editRentalModel = self.editRentalModel
            }
            if let name = self.selectedtrailer{
                durationVC.selectedtrailer = name
            }
        }
    }
}


class DateHeader: JTAppleCollectionReusableView  {
    @IBOutlet var monthTitle: UILabel!
}

extension Date {
    var day : Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let day = formatter.string(from: self)
        return Int(day) ?? 0
    }
    
    var month : Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        let month = formatter.string(from: self)
        return Int(month) ?? 0
    }
    
    static var today: Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        let todayDate = formatter.date(from: todayString)
        return todayDate!
    }
}
