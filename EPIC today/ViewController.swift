//
//  ViewController.swift
//  EPIC today
//
//  Created by Mialin Valentin on 21.06.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SwiftyJSON
import CoreLocation

class EPIC {
    var imageName:String
    var urlString:String
    var date:Date
    var distanceToEarth:Double
    var distanceToSun:Double
    var sevAngle:Double

    
    init(imageName:String, urlString:String, date:Date, distanceToEarth:Double, distanceToSun:Double, sevAngle:Double) {
        self.imageName = imageName
        self.urlString = urlString
        self.date = date
        self.distanceToEarth = distanceToEarth
        self.distanceToSun = distanceToSun
        self.sevAngle = sevAngle

    }
    
}

class ECI {
    
    var x:Double
    var y:Double
    var z:Double
    
    init?(x:Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
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
    @IBOutlet var infoView: UIView!
    @IBOutlet var distanceToEarthLabbel: UILabel!
    @IBOutlet var distanceToSunLabbel: UILabel!
    @IBOutlet var sevAngleLabel: UILabel!
    

    let locationManager = CLLocationManager()
    
    var infoViewIsHidden:Bool = true
    
  //  var locationCurent = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        configureLocationServices()
        
        //scrollView
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        
        loadImage()


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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !infoViewIsHidden {
            if scrollView.zoomScale <= 1 {
                setView(view: infoView, hidden: false)
            }
            else{
                setView(view: infoView, hidden: true)
            }
        }
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

    func getEpic(completion: @escaping  ([EPIC]) -> ()) {

        
        var epicArray = [EPIC]()
        
        let url = URL(string: "https://api.nasa.gov/EPIC/api/natural/")!
        
        self.imageActivityIndicator.startAnimating()
        
        Alamofire.request(url, method: .get, parameters: ["api_key": "zy0Q17y4wvS2SDDmNSxPgaKq7nFIbaCJmza4t7Qs"]).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                
                var distanceMin:Int?
                var jsonCurrent:JSON = [:]
                
                for item in json.arrayValue{
                    
                    let lat = item["centroid_coordinates"]["lat"].doubleValue
                    let lon = item["centroid_coordinates"]["lon"].doubleValue
                    
                    let coordinates = CLLocation(latitude: lat, longitude: lon)
                    
                    var distance = Int()
                    
                    if let locationCurent = self.locationManager.location{
                        distance = Int((locationCurent.distance(from: coordinates)))
                    }else{
                        distance = Int((CLLocation(latitude: 0.0, longitude: 0.0).distance(from: coordinates)))
                    }
                    
                    if distanceMin == nil || distance < distanceMin! {
                        jsonCurrent = item
                        distanceMin = distance
                    }
                    
                }
                
                    let dscovr = ECI(x: jsonCurrent["dscovr_j2000_position"]["x"].doubleValue,
                                                    y: jsonCurrent["dscovr_j2000_position"]["y"].doubleValue,
                                                    z: jsonCurrent["dscovr_j2000_position"]["z"].doubleValue)!
                    
                    let sun = ECI(x: jsonCurrent["sun_j2000_position"]["x"].doubleValue,
                                                 y: jsonCurrent["sun_j2000_position"]["y"].doubleValue,
                                                 z: jsonCurrent["sun_j2000_position"]["z"].doubleValue)!
                    
                    
                    let sev = acos((dscovr.x * sun.x + dscovr.y * sun.y + dscovr.z * sun.z)/(sqrt(pow(dscovr.x, 2) + pow(dscovr.y, 2) + pow(dscovr.z, 2))*(sqrt(pow(sun.x, 2) + pow(sun.y, 2) + pow(sun.z, 2)))))*180/Double.pi
                    
                  //  print(acos(a)*180/Double.pi)
                   // print(String(format:"%.2f", acos(a)*180/Double.pi))

                    let imageUrlString = "https://epic.gsfc.nasa.gov/archive/natural/\(dateFormatter.string(from: jsonCurrent["date"].date!))/png/\(jsonCurrent["image"].stringValue).png"
                
                    epicArray.append(EPIC(imageName: jsonCurrent["image"].stringValue, urlString: imageUrlString, date: jsonCurrent["date"].date!, distanceToEarth: self.distanceInSpace(from: ECI(x: 0, y: 0, z: 0)!, before: dscovr), distanceToSun: self.distanceInSpace(from: ECI(x: 0, y: 0, z: 0)!, before: sun), sevAngle: sev))
                
                
            // print(epicArray)
            case .failure(let error):
                print(error)
            }
            completion(epicArray)
        }

    }
    
    func loadImage() {
        getEpic { (getEpic : [EPIC]) in
            
            let URL = NSURL(string: getEpic[0].urlString)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            self.title = dateFormatter.string(from: getEpic[0].date)
            
            let distanceToEarth = Measurement(value: getEpic[0].distanceToEarth, unit: UnitLength.meters)
            self.distanceToEarthLabbel.text = MeasurementFormatter().string(from: distanceToEarth)
            
            let distanceToSun = Measurement(value: getEpic[0].distanceToSun, unit: UnitLength.meters)
            self.distanceToSunLabbel.text = MeasurementFormatter().string(from: distanceToSun)

            self.sevAngleLabel.text = String(format:"%.2f", getEpic[0].sevAngle) + "°"
            
            self.imageView.af_setImage(withURL: URL as URL, progress: { (NSProgress) in
                if NSProgress.fractionCompleted == 1 {
                    self.imageActivityIndicator.stopAnimating()
                }
                else{
                    self.imageActivityIndicator.startAnimating()
                }
            })

        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     //   if let location = locations.first {
          //  print("Current locatiom \(location)")

     //   }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
 
    
    //MARK: Share
    @IBAction func shareButton(_ sender: Any) {
        
        // image to share
        if let imageToShare = self.imageView.image {
        
        let shareText = "Изображение земли"
            
        // set up activity view controller
        let activityViewController = UIActivityViewController(activityItems: [imageToShare, shareText], applicationActivities: nil)
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    //MARK: Info
    @IBAction func infoButton(_ sender: Any) {
        
        if infoView.isHidden {
            setView(view: infoView, hidden: false)
            infoViewIsHidden = false
        }
        else{
            setView(view: infoView, hidden: true)
            infoViewIsHidden = true
        }
        
        
        if scrollView.zoomScale <= 1 {
            setView(view: infoView, hidden: false)
        }
        else{
            setView(view: infoView, hidden: true)
            scrollView.zoomScale = 1
        }
        
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { _ in
            view.isHidden = hidden
        }, completion: nil)
    }
    
    func distanceInSpace(from: ECI, before: ECI) -> Double {
       
        return sqrt(pow(from.x - before.x, 2) + pow(from.y - before.y, 2) + pow(from.z - before.z, 2))
    }
}

