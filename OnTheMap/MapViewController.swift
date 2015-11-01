//
//  MapViewController.swift
//  OnTheMap
//
//  Created by 咩咩 on 15/10/25.
//  Copyright © 2015年 Wenzhe. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locations: [StudentInfo] = [StudentInfo]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locations = ParseClient.sharedInstance().students
        var annotations = [MKPointAnnotation]()
        mapView.delegate = self
        
        for location in locations {

            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
        /* Create and set the top buttons */
        self.parentViewController!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Reply, target: self, action: "logoutButtonTouchUp")
        self.parentViewController!.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonTouchUp")]
        self.parentViewController!.navigationItem.rightBarButtonItems!.append(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonTouchUp"))
    }
    
    func logoutButtonTouchUp() {
        UdacityClient.sharedInstance().deleteSession()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshButtonTouchUp() {
        ParseClient.sharedInstance().getStudentLocations() { (success, errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(), {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            }
        }
        //locations = ParseClient.sharedInstance().students
        
    }
    
    func addButtonTouchUp(){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AddPinViewController") as! AddPinViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
}