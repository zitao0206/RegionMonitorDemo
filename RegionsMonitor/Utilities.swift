//
//  Utilities.swift
//  RegionsMonitor
//
//  Created by lizitao on 2023-09-13.
//

import UIKit
import MapKit

class Utilities {
    static func showSimpleAlertWithTitle(_ title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func zoomToUserLocation(in mapView: MKMapView) {
        if let location = mapView.userLocation.location {
            let coordinate = location.coordinate
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000.0, longitudinalMeters: 10000.0)
            mapView.setRegion(region, animated: true)
        }
        
    }
}
