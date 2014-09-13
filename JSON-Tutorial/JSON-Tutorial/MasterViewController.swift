//
//  MasterViewController.swift
//  JSON-Tutorial
//
//  Created by Benjamin Herzog on 30.07.14.
//  Copyright (c) 2014 Benjamin Herzog. All rights reserved.
//

import UIKit

let kURL = "https://itunes.apple.com/search?term=facebook&entity=software&attribute=softwareDeveloper&country=de"
let mainQueue = dispatch_get_main_queue()
let diffQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

class MasterViewController: UITableViewController {

    var daten = NSMutableArray()
    var images = [String:UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Facebook"
        
        let request = NSURLRequest(URL: NSURL(string: kURL))
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            
            if error != nil {
                println(error!.localizedDescription)
                return
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                var errorV: NSError?
                self.daten = (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &errorV) as NSDictionary)["results"] as NSMutableArray
                if errorV != nil {
                    println(errorV!.localizedDescription)
                    return
                }
                for dic in self.daten {
                    let url = dic["artworkUrl60"] as String
                    let data = NSData(contentsOfURL: NSURL(string: url))
                    let image = UIImage(data: data)
                    self.images["\(self.daten.indexOfObject(dic))"] = image
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
            
            })
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daten.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        cell.textLabel?.text = (daten[indexPath.row] as NSDictionary)["trackName"] as? String
        if images["\(indexPath.row)"] != nil {
            cell.imageView?.image = images["\(indexPath.row)"]!
            cell.imageView?.layer.cornerRadius = 10
            cell.imageView?.clipsToBounds = true
        }
        let version = (daten[indexPath.row] as NSDictionary)["version"] as String
        let preis = (daten[indexPath.row] as NSDictionary)["price"] as Double
        
        cell.detailTextLabel?.text = "Version: \(version) Preis: \(preis)€"
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = (daten[indexPath.row] as NSDictionary)["trackViewUrl"] as String
        let alert = UIAlertController(title: "App Store", message: "Wollen Sie wirklich den App Store öffnen?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Nein", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ja", style: .Default, handler: {
            action in
            
            UIApplication.sharedApplication().openURL(NSURL(string: url))
            return
            }))
        presentViewController(alert, animated: true, completion: nil)
    }


}
















