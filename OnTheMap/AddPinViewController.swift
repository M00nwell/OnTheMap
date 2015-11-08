//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by 咩咩 on 15/10/25.
//  Copyright © 2015年 Wenzhe. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AddPinViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var locationCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D()
    let parse = ParseClient.sharedInstance()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        topLabel.hidden = false
        locationTextField.hidden = false
        locationTextField.text = ""
        locateButton.hidden = false
        warningLabel.frame.origin.y = 234
        warningLabel.text = ""
        mapView.hidden = true
        linkTextField.hidden = true
        submitButton.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPressed")
    }
    
    @IBAction func findPressed(sender: UIButton) {
        if locationTextField.text == "" {
            warningLabel.text = "Location Empty"
            return
        }
        
        ActivityIndicatorView.shared.showProgressView(view)
        
        let address = locationTextField.text!
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {(placemarks, error) in
            if let error = error {
                print(error)
                dispatch_async(dispatch_get_main_queue(), {
                    self.warningLabel.text = "Failed to Locate on the Map"
                    ActivityIndicatorView.shared.hideProgressView()
                })
                return
            }else {
                self.findOnMap(placemarks)
                ActivityIndicatorView.shared.hideProgressView()
            }
        }
        
    }
    @IBAction func submitPressed(sender: UIButton) {
        if linkTextField.text == "" {
            warningLabel.text = "Link Empty"
            return
        }
        
        ActivityIndicatorView.shared.showProgressView(view)
        
        parse.queryStudentLocation() { (success, count, errorString) in
            if success {
                if count == 0 { //first submit
                    self.addLocation()
                }else{ // already submitted before, warn for replacing
                    let alert = UIAlertController(title: "Alert", message: "Do you want to replace your pin?", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                        self.replaceLocation()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        ActivityIndicatorView.shared.hideProgressView()
                    }))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            }else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.warningLabel.text = errorString
                    ActivityIndicatorView.shared.hideProgressView()
                })
            }
        }
    }
    
    func cancelPressed() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func findOnMap(placemarks: [CLPlacemark]?) {
        if let placemark = placemarks?[0] {
            if let coordinate = placemark.location?.coordinate {
                locationCoordinate = coordinate
                if let circularRegion = placemark.region as? CLCircularRegion{
                    let scalingFactor = abs( (cos(2 * M_PI * coordinate.latitude / 360.0) ))
                    let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(circularRegion.radius/111045, circularRegion.radius/(scalingFactor*111045))
                    let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
                    let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    dispatch_async(dispatch_get_main_queue(), {
                        self.mapView.hidden = false
                        self.linkTextField.hidden = false
                        self.submitButton.hidden = false
                        self.view.bringSubviewToFront(self.submitButton)
                        //self.submitButton.userInteractionEnabled = true
                        self.topLabel.hidden = true
                        self.locationTextField.hidden = true
                        self.locateButton.hidden = true
                        self.warningLabel.text = ""
                        self.warningLabel.layer.zPosition = CGFloat(1)
                        self.mapView.setRegion(region, animated: true)
                        self.mapView.addAnnotation(annotation)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.warningLabel.text = "Failed to Locate on the Map"
                    })
                    return
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.warningLabel.text = "Failed to Locate on the Map"
                })
                return
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), {
                self.warningLabel.text = "Failed to Locate on the Map"
            })
            return
        }
    }
    
    func addLocation(){
        parse.addStudentLocation(locationTextField.text!, mediaUrl: linkTextField.text!, latitude: locationCoordinate.latitude, Longitude: locationCoordinate.longitude) { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    ActivityIndicatorView.shared.hideProgressView()
                    self.navigationController?.popViewControllerAnimated(false)
                    self.parse.mapNeedReload = true
                    self.parse.listNeedReload = true
                })
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.warningLabel.text = errorString
                    ActivityIndicatorView.shared.hideProgressView()
                })
            }
        }
    }
    
    func replaceLocation(){
        parse.replaceStudentLocation(locationTextField.text!, mediaUrl: linkTextField.text!, latitude: locationCoordinate.latitude, Longitude: locationCoordinate.longitude) { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    ActivityIndicatorView.shared.hideProgressView()
                    self.navigationController?.popViewControllerAnimated(false)
                    self.parse.mapNeedReload = true
                    self.parse.listNeedReload = true
                })
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.warningLabel.text = errorString
                    ActivityIndicatorView.shared.hideProgressView()
                })
            }
        }
    }
    
}