//
//  TrackingViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 08/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import MapKit
import SocketIO

class TrackingViewController: UIViewController { 
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bottomCard: UIView!
    
    var source: CLLocationCoordinate2D?
    var destination: CLLocationCoordinate2D?
    var inVoiceID : String = ""
    
    let manager = SocketManager(socketURL: baseURL!,config: [.log(true)])
    
    var socket : SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
        self.socket = manager.defaultSocket
        self.socket.connect()
        
        ServiceController.shared.sendLocationStartData(rentalId: inVoiceID, type: "dropoff", action: "start") { (success, location, error) in
            if success {
                self.destination = location.coordinates
                self.setupSocket()
            }
        }
        
        ServiceController.shared.getRental(withID: inVoiceID) { (status, invoice, error) in
            if status {
                
            }
        }
        
    }
    
    func setupSocket(){
        
        self.socket.on(clientEvent: .connect) { (data, ack) in
            print("socket connected")
            
            let data = InvoiceData(invoiceNumber: self.inVoiceID)
            
            let myData = try! JSONEncoder().encode(data)
            
            self.socket.emit("userJoin", myData){
                print("User Joined")
                self.fetchCoordinates()
            }
        }
    }
    
    func fetchCoordinates(){
        self.socket.on("trackingData") { (data, ack) in
            DispatchQueue.main.async {
                self.source = self.getCoordinates(data)
                self.reload()
            }
        }
    }
    
    func initialSetup(){
        mapView.layer.cornerRadius = 12
        bottomCard.makeBottomCard()
        bottomCard.layer.cornerRadius = 12
        refreshButton.layer.cornerRadius = refreshButton.frame.height/2
        overrideUserInterfaceStyle = .light
        mapView.delegate = self
    }
    
    
    func getCoordinates(_ datas : [Any])->CLLocationCoordinate2D?{
        guard let data = datas.first as? Data else { return nil }
        do {
            let location = try JSONDecoder().decode(LocationData.self, from: data)
            print("SOURCE COORD",location.lat,location.long)
            let lat = location.lat.coord
            let lon = location.long.coord
            print("DOUBLE COORD",lat,lon)
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return coord
        } catch {
            print("Location Error:",error)
            return nil
        }
    }
    
    func loadMap() {
        guard let source = source else { return }
        let viewRegion = MKCoordinateRegion(center: source, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(viewRegion, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func reload(){
        loadMap()
        guard let source = source, let destination = destination else { return }
        print("SDSD",source,destination)
        let (sourceMapItem, destinationMapItem) = setupForDirection(pickupCoordinate: source, destinationCoordinate: destination)
        showRouteOnMap(sourceMapItem: sourceMapItem, destinationMapItem: destinationMapItem)
        getExpectedTime(sourceMapItem: sourceMapItem, destinationMapItem: destinationMapItem)
    }
}

extension TrackingViewController : MKMapViewDelegate {
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func setupForDirection(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) -> (MKMapItem, MKMapItem){
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        return (sourceMapItem, destinationMapItem)
    }
    
    // MARK: - showRouteOnMap
    
    func showRouteOnMap(sourceMapItem: MKMapItem, destinationMapItem: MKMapItem) {
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {(response, error)  in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func getExpectedTime(sourceMapItem: MKMapItem, destinationMapItem: MKMapItem) {
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculateETA { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            let time = response.expectedTravelTime
            let (hours, mins, _) = self.secondsToHoursMinutesSeconds(seconds: Int(time))
            if hours > 0 {
                if hours >= 1 {
                    self.timeLabel.text = "\(hours) hour, \(mins) minutes away"
                }
                else {
                    self.timeLabel.text = "\(hours) hours, \(mins) minutes away"
                }
            }
            else if mins > 1 {
                self.timeLabel.text = "\(mins) minutes away"
            }
            else {
                self.timeLabel.text = "< \(mins) minute away"
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .primary
        renderer.lineWidth = 4.0
        return renderer
    }
}


struct InvoiceData : Codable {
    let invoiceNumber: String
}

struct LocationData : Codable {
    let invoiceNumber: String
    let lat: String
    let long : String
}

extension String {
    var coord : CLLocationDegrees {
        if let val = Double(self){
            return val
        } else {
            return 0.0
        }
    }
}
