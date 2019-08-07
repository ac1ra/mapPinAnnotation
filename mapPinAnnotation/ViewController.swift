//
//  ViewController.swift
//  mapPinAnnotation
//
//  Created by ac1ra on 07/08/2019.
//  Copyright © 2019 ac1ra. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    var names:[String]!
    var images:[String]!
    var descriptions:[String]!
    var coordinates:[Any]!
    var currentRestaurantIndex: Int = 0
    var locationManager: CLLocationManager!
    
    var restaurantImages =  ["restaurant-1.jpeg", "restaurant-2.jpeg","restaurant-3.jpeg", "restaurant-4.jpeg","restaurant-5.jpeg", "restaurant-6.jpeg","restaurant-7.jpeg","restaurant-8.jpeg"]
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func showNext(_ sender: Any) {
        //1:This is a simple test as you click the tool bar button to iterate over the array items. If you reach the last restaurant in the list, it will be reset to 0 to show the first item and goes from there.
        
        if currentRestaurantIndex > names.count - 1{
            currentRestaurantIndex = 0
        }
        //2: Here you used the currentRestaurantIndex value to get the restaurant coordinates, name and image informations. Then, you constructed a custom annotation object to store those informations for later use in the mapView:viewForAnnotation: protocol method.
        
        let coordinate = coordinates[currentRestaurantIndex] as! [Double]
        let latitude: Double = coordinate[0]
        let londitude: Double = coordinate[1]
        let locationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: londitude)
        
        var point = RestaurantAnnotation(coordinate:locationCoordinates)
        
        point.title = names[currentRestaurantIndex]
//        point.image = images[currentRestaurantIndex]
        //3
        //Calculate Transist ETA Request
        let request = MKDirections.Request()
        /*Source MKMapItem*/
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil))
        request.source = sourceItem
//        //Destination MKMapItem
//        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: locationCoordinates, addressDictionary: nil))
//        request.source = sourceItem
        //Destination MKMapItem
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: locationCoordinates, addressDictionary: nil))
        request.destination = destinationItem
        request.requestsAlternateRoutes = false
        
        request.transportType = .transit
        
        mapView.setCenter(locationCoordinates, animated: true)
        
        let directions = MKDirections(request: request)
        
        directions.calculateETA{(etaResponse, error) -> Void in
            if let error = error{
                print("Error while requesting ETA: \(error.localizedDescription)")
                point.eta = error.localizedDescription
            } else{
                point.eta = "\(Int((etaResponse?.expectedTravelTime)!/60)) min"
            }
            //4
            var isExist = false
            for annotation in self.mapView.annotations{
                if annotation.coordinate.longitude == point.coordinate.longitude && annotation.coordinate.latitude == point.coordinate.latitude{
                    isExist = true
                    point = annotation as! RestaurantAnnotation
                }
            }
            if !isExist{
                self.mapView.addAnnotation(point)
            }
            self.mapView.selectAnnotation(point, animated: true)
            self.currentRestaurantIndex += 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    // Some restaurants in London
    names = ["Pied a Terre", "Big Ben", "Hawksmoor Seven Dials", "Enoteca Turi", "Wiltons", "Scott's", "The Laughing Gravy", "Restaurant Gordon Ramsay"]
    
    // Restaurants' images to show in the pin callout
        images = UIImage(named: restaurantImages)
        
    // Latitudes, Longitudes
    coordinates = [
    [51.519066, -0.135200],
    [51.513446, -0.125787],
    [51.465314, -0.214795],
    [51.507747, -0.139134],
    [51.509878, -0.150952],
    [51.501041, -0.104098],
    [51.485411, -0.162042],
    [51.513117, -0.142319]
    ]
    
    currentRestaurantIndex = 0 // Start with the first Restaurant in the array

        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotation{
//        if !(annotation is RestaurantAnnotation) {
//            return nil
//        }
        var  annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = true
        } else{
            annotationView?.annotation = annotation
        }
        let restaurantAnnotaion = annotation as! RestaurantAnnotation
        annotationView?.detailCalloutAccessoryView = UIImageView(image: restaurantAnnotaion.image)
        //Left accessory
        let leftAccessory = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        leftAccessory.text = restaurantAnnotaion.eta
        leftAccessory.font = UIFont(name: "Verdana", size: 10)
        annotationView?.leftCalloutAccessoryView = leftAccessory
        
        //Righr accessory view
        let image = UIImage(named: "bus.png")
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(image, for: UIControl.State())
        annotationView?.rightCalloutAccessoryView = button
        return annotationView as! MKAnnotation
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}
