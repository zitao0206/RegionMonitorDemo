//
//  Geotification.swift
//  RegionsMonitor
//
//  Created by lizitao on 2023-09-13.
//

import Foundation
import CoreLocation
import MapKit

enum EventType: Int {
    case OnEntry = 0
    case OnExit
}

class Geotification: NSObject, NSCoding, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var eventType: EventType
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.eventType = eventType
    }
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType == .OnEntry ? "On Entry" : "On Exit"
        return String(format: "Radius: %.2f m - %@", radius, eventTypeString)
    }
    
    required init?(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDouble(forKey: "latitude")
        let longitude = aDecoder.decodeDouble(forKey: "longitude")
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = aDecoder.decodeDouble(forKey: "radius")
        identifier = aDecoder.decodeObject(forKey: "identifier") as? String ?? ""
        note = aDecoder.decodeObject(forKey: "note") as? String ?? ""
        eventType = EventType(rawValue: aDecoder.decodeInteger(forKey: "eventType")) ?? .OnEntry
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(coordinate.latitude, forKey: "latitude")
        aCoder.encode(coordinate.longitude, forKey: "longitude")
        aCoder.encode(radius, forKey: "radius")
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(eventType.rawValue, forKey: "eventType")
    }
}

