//
//  RestaurantAnnotation.swift
//  mapPinAnnotation
//
//  Created by ac1ra on 07/08/2019.
//  Copyright © 2019 ac1ra. All rights reserved.
//

import UIKit
import MapKit

class RestaurantAnnotation: NSObject,MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var image: UIImage?
    var eta: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
