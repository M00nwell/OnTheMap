//
//  ListViewController.swift
//  OnTheMap
//
//  Created by 咩咩 on 15/10/25.
//  Copyright © 2015年 Wenzhe. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let parse = ParseClient.sharedInstance()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if ParseClient.sharedInstance().listNeedReload {
            refreshButtonTouchUp()
            ParseClient.sharedInstance().listNeedReload = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.parentViewController!.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonTouchUp")
    }
    
    func refreshButtonTouchUp() {
        ActivityIndicatorView.shared.showProgressView(view)
        ParseClient.sharedInstance().getStudentLocations() { (success, errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(), {
                    ActivityIndicatorView.shared.hideProgressView()
                    self.tableView.reloadData()
                })
            } else{
                LogInViewController.showAlert(errorString!, vc: self)
            }
        }
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "TableViewCell"
        let location = parse.students[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        cell.textLabel!.text = location.firstName + " " + location.lastName
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parse.students.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        let toOpen = parse.students[indexPath.row].mediaURL
        if toOpen != "" {
            app.openURL(NSURL(string: toOpen)!)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
}