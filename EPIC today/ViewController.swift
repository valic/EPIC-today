//
//  ViewController.swift
//  EPIC today
//
//  Created by Mialin Valentin on 21.06.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit
import ImageSlideshow
import AlamofireImage
import Alamofire
import SwiftyJSON
import CoreLocation

class epic {
    var imageName:String
    var urlString:String
    var date:Date
    var distance:Int
    
    init(imageName:String, urlString:String, distance:Int, date:Date) {
        self.imageName = imageName
        self.urlString = urlString
        self.distance = distance
        self.date = date
    }
    
}

extension JSON {
    public var date: Date? {
        get {
            if let str = self.string {
                return JSON.jsonDateFormatter.date(from: str)
            }
            return nil
        }
    }
    
    private static let jsonDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()
}

class ViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageActivityIndicator: UIActivityIndicatorView!

    let locationManager = CLLocationManager()
    
    var locationCurent = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        configureLocationServices()
        
        //scrollView
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0


    }
    
    func configureLocationServices() {
        // Send location updates to the current object.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.requestLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .restricted:
            print("restricted by e.g. parental controls. User can't enable Location Services")
            break
        case .denied:
            print("user denied your app access to Location Services, but can grant access from Settings.app")
            break
        }
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @IBAction func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        let newCenter = imageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    func getEpic(completion: @escaping  ([epic]) -> ()) {
        
        var epicArray = [epic]()
        
        let url = URL(string: "https://api.nasa.gov/EPIC/api/natural/")!
        
        //self.imageActivityIndicator.startAnimating()
        
        Alamofire.request(url, method: .get, parameters: ["api_key": "zy0Q17y4wvS2SDDmNSxPgaKq7nFIbaCJmza4t7Qs"]).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                
                for item in json.arrayValue{
                    
                    let lat = item["centroid_coordinates"]["lat"].doubleValue
                    let lon = item["centroid_coordinates"]["lon"].doubleValue
                    
                    let coordinates = CLLocation(latitude: lat, longitude: lon)
                    

                    
                    let distance = Int(self.locationCurent.distance(from: coordinates))
                    
                    let imageUrlString = "https://epic.gsfc.nasa.gov/archive/natural/\(dateFormatter.string(from: item["date"].date!))/png/\(item["image"].stringValue).png"
                    epicArray.append(epic(imageName: item["image"].stringValue, urlString: imageUrlString, distance: distance, date: item["date"].date!))
                }
                
            // print(epicArray)
            case .failure(let error):
                print(error)
            }
            completion(epicArray)
        }

    }
    
    func loadImage() {
        getEpic { (getEpic : [epic]) in
            
            let epic = getEpic.sorted{$0.distance < $1.distance}
            let URL = NSURL(string: epic[0].urlString)!
            
            //self.imageView.af_setImage(withURL: URL as URL)
            
            
            
            self.imageView.af_setImage(withURL: URL as URL, progress: { (NSProgress) in
                if NSProgress.fractionCompleted == 1 {
                    self.imageActivityIndicator.stopAnimating()
                }
                else{
                    self.imageActivityIndicator.startAnimating()
                }
            })

            
                /*
            self.imageActivityIndicator.startAnimating()
            self.imageView.af_setImage(withURL: URL as URL, completion: { response in
                self.imageActivityIndicator.stopAnimating()

            })
            */
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.locationCurent = location
            
            print("Current locatiom \(location)")
            loadImage()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        loadImage()
    }
    
    //MARK: Share
    @IBAction func shareButton(_ sender: Any) {
        
        // image to share
        if let imageToShare = self.imageView.image {
        
        let shareText = "Изображение земли"
            
        // set up activity view controller
        let activityViewController = UIActivityViewController(activityItems: [imageToShare, shareText], applicationActivities: nil)
        //activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
      //  activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
}

