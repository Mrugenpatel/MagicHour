//
//  ViewController.swift
//  MagicHour
//
//  Created by higuchiryunosuke on 2020/01/08.
//  Copyright © 2020 higuchiryunosuke. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var canSeeSunsetLabel: UILabel!
    
    let apiKey = "e846088f82debcd7f279c5792dceb51b"
    var lat = 26.8205
    var lon = 30.8024
    // loading
    var activityIndicator: NVActivityIndicatorView!
    // user location
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        // use popup to check and get location
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        print(location)
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON {
            
            response in
            
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let jsonSunset = jsonResponse["sys"]["sunset"].stringValue
                // whether you can see the sunset or not
                let jsonCanSeeSunset = jsonWeather["main"]
                if jsonCanSeeSunset == "Clear" || jsonCanSeeSunset == "Sunny" {
                    self.canSeeSunsetLabel.text = "Yes"
                } else {
                    self.canSeeSunsetLabel.text = "Nope"
                }
                //about sunset(converting from date to string)
                let dt = jsonSunset
                if let unixTime1 = TimeInterval(dt) {
                    let stringTime1 = Date(timeIntervalSince1970: unixTime1)
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    self.sunsetLabel.text = df.string(from: stringTime1)
                }
                //lat and lon
                self.latLabel.text = String(self.lat)
                self.lonLabel.text = String(self.lon)
                //other labels
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.conditionLabel.text = jsonWeather["main"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
            }
        }
    }
}



