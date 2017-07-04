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
import Onboard
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

enum ColorImagery {
    case natural
    case enhanced
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
    @IBOutlet var bottomView: UIView!
    @IBOutlet var distanceToEarthLabbel: UILabel!
    @IBOutlet var distanceToSunLabbel: UILabel!
    @IBOutlet var sevAngleLabel: UILabel!
    
    
    let locationManager = CLLocationManager()
    
    var infoViewIsHidden:Bool = true
    var currentDate = Date()
    var currentColor = ColorImagery.natural
    var errorSubview:ErrorSubview?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        configureLocationServices()
        
        //scrollView
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        
        // Single Tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singleTap.numberOfTapsRequired = 1
        self.scrollView.addGestureRecognizer(singleTap)
        
        // Double Tap
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
        
        loadImage(color: currentColor, date: nil)
    }
    

    
    @IBAction func infoButton(_ sender: AnyObject) {
        presentAnnotation()
    }
    
    func presentAnnotation() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Annotation") as! AnnotationViewController
        viewController.alpha = 0.5
        present(viewController, animated: true, completion: nil)
    }
    
    func getEpic(color: ColorImagery, date: Date?, completion: @escaping  ([EPIC]) -> ()) {
        
        var epicArray = [EPIC]()
        var urlString = ""
        
        switch color {
        case .natural:
            urlString = "https://api.nasa.gov/EPIC/api/natural/"
        case .enhanced:
            urlString = "https://api.nasa.gov/EPIC/api/enhanced/"
        }
        
        if date != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            urlString = urlString + "date/" + dateFormatter.string(from: date!)
        }
        
        let url = URL(string: urlString)!
        
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
                
                var imageUrlString = ""
                
                switch color {
                case .natural:
                    imageUrlString = "https://epic.gsfc.nasa.gov/archive/natural/\(dateFormatter.string(from: jsonCurrent["date"].date!))/png/\(jsonCurrent["image"].stringValue).png"
                case .enhanced:
                    imageUrlString = "https://epic.gsfc.nasa.gov/archive/enhanced/\(dateFormatter.string(from: jsonCurrent["date"].date!))/png/\(jsonCurrent["image"].stringValue).png"
                    
                }
                epicArray.append(EPIC(imageName: jsonCurrent["image"].stringValue, urlString: imageUrlString, date: jsonCurrent["date"].date!, distanceToEarth: self.distanceInSpace(from: ECI(x: 0, y: 0, z: 0)!, before: dscovr), distanceToSun: self.distanceInSpace(from: ECI(x: 0, y: 0, z: 0)!, before: sun), sevAngle: sev))
                
            case .failure(let error):
                self.showErrorSubview(error: error)
            }
            completion(epicArray)
        }
    }
    
    func loadImage(color: ColorImagery, date: Date?) {
        
        // Start load animating
        self.imageActivityIndicator.startAnimating()
        
        getEpic(color: color, date: date) { (getEpic : [EPIC]) in
            
            if !getEpic.isEmpty {
                
                let URL = NSURL(string: getEpic[0].urlString)!
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                self.title = dateFormatter.string(from: getEpic[0].date)
                self.currentDate = getEpic[0].date
                
                let distanceToEarth = Measurement(value: getEpic[0].distanceToEarth, unit: UnitLength.meters)
                self.distanceToEarthLabbel.text = MeasurementFormatter().string(from: distanceToEarth)
                
                let distanceToSun = Measurement(value: getEpic[0].distanceToSun, unit: UnitLength.meters)
                self.distanceToSunLabbel.text = MeasurementFormatter().string(from: distanceToSun)
                
                self.sevAngleLabel.text = String(format:"%.2f", getEpic[0].sevAngle) + "°"
                
                self.imageView.contentMode = .scaleAspectFit
                
                // Download image
                self.imageView.af_setImage(withURL: URL as URL, progress: {NSProgress in
                    
                    if NSProgress.fractionCompleted == 1 {
                        self.imageActivityIndicator.stopAnimating()
                    }
                    else{
                        self.imageActivityIndicator.startAnimating()
                    }
                }, completion: { response in
                    
                    if let error = response.result.error {
                        self.showErrorSubview(error: error)
                    }
                    if response.result.isSuccess {
                        self.imageActivityIndicator.stopAnimating()
                        self.closeErrorSubview()
                    }
                })
            }
        }
    }
    
    
    //MARK: Location
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //   if let location = locations.first {
        //  print("Current locatiom \(location)")
        
        //   }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    //MARK: TapGesture
    func singleTapped(recognizer: UITapGestureRecognizer) {
        
        print("singleTapped")
        if infoView.isHidden {
            setView(view: infoView, hidden: false)
            infoViewIsHidden = false
            
            if scrollView.zoomScale <= 1 {
                setView(view: infoView, hidden: false)
            }
            else{
                setView(view: infoView, hidden: true)
            }
        }
        else{
            setView(view: infoView, hidden: true)
            infoViewIsHidden = true
        }
        
    }
    
    func doubleTapped(recognizer: UITapGestureRecognizer) {
        print("doubleTapped")
        
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
            
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    //MARK: Zomming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale <= 1 {
            setView(view: bottomView, hidden: false)
        }
        else{
            setView(view: bottomView, hidden: true)
        }
        
        if !infoViewIsHidden {
            if scrollView.zoomScale <= 1 {
                setView(view: infoView, hidden: false)
            }
            else{
                setView(view: infoView, hidden: true)
            }
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
    
    //MART: ColorImagery
    @IBAction func colorImagery(_ sender: Any) {
        switch currentColor {
        case .natural:
            currentColor = .enhanced
        case .enhanced:
            currentColor = .natural
        }
        loadImage(color: currentColor, date: nil)
    }
    
    //MART: What is EPIC?
    @IBAction func whatIsEPIC(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://epic.gsfc.nasa.gov/epic")!, options: [:], completionHandler: nil)
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { _ in
            view.isHidden = hidden
        }, completion: nil)
    }
    
    func distanceInSpace(from: ECI, before: ECI) -> Double {
        return sqrt(pow(from.x - before.x, 2) + pow(from.y - before.y, 2) + pow(from.z - before.z, 2))
    }
    
    //MARK: ErrorSubview
    func showErrorSubview(error: Error) {
        closeErrorSubview()
        
        self.errorSubview = ErrorSubview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.errorSubview?.errorStringLabel.text = error.localizedDescription
        self.errorSubview?.reloadPressed.addTarget(self, action: #selector(reload(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(self.errorSubview!)
    }
    
    func closeErrorSubview() {
        for view in self.view.subviews {
            if view is ErrorSubview {
                view.removeFromSuperview()
            }
        }
    }
    
    func reload(_ sender:UIButton) {
        loadImage(color: currentColor, date: nil)
    }
    

    
}



