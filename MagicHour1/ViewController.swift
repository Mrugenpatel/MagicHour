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
import UserNotifications
class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var canSeeSunsetLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    let apiKey = "e846088f82debcd7f279c5792dceb51b"
    var lat = 26.8205
    var lon = 30.8024
    // loading
    var activityIndicator: NVActivityIndicatorView!
    // user location
    let locationManager = CLLocationManager()
    let dateFormatter = DateFormatter()
    // after load
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
        //
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        //date
        let date = Date()
        let dateName = date.weekday
        dateLabel.text = dateName
    }
    //About weather API
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let jsonIcon = jsonWeather["icon"].stringValue
                let jsonSunset = jsonResponse["sys"]["sunset"].stringValue
                //image change
                self.conditionImage.image = UIImage(named: jsonIcon)
                //about sunset(converting from date to string)
                let dt = jsonSunset
                if let unixTime1 = TimeInterval(dt) {
                    let stringTime1 = Date(timeIntervalSince1970: unixTime1)
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    self.sunsetLabel.text = df.string(from: stringTime1)
                }
                //other labels
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                // whether you can see the sunset or not
                //date
                let notificationTime = DateComponents()
                let hour = notificationTime.hour
                let minute = notificationTime.minute
                let jsonCanSeeSunset = jsonWeather["main"]
                if jsonCanSeeSunset == "Clear" || jsonCanSeeSunset == "Sunny" {
                    self.canSeeSunsetLabel.text = "Yes"
                    if hour == 14 && minute == 00 {
                        self.setLocalNotification(title:"MagicHourです！", message:"本日は天気が良いのでいい夕日が観れるかもしれません！")
                    }
                } else {
                   self.canSeeSunsetLabel.text = "Nope"
               }
            }
        }
    }
    //local notification
    func setLocalNotification(title:String = "", message:String, hour:Int = 14, minute:Int = 0, second:Int = 0 ){
        // title, message, sound
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        //date
        var notificationTime = DateComponents()
        notificationTime.hour = hour
        notificationTime.minute = minute
        notificationTime.second = second
        let trigger: UNNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: false)
        //identifier
        let request = UNNotificationRequest(identifier: "MagicHour", content: content, trigger: trigger)
        // register local notification
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

extension Date {
    var weekday: String {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.component(.weekday, from: self)
        let weekday = component - 1
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        return formatter.weekdaySymbols[weekday]
    }
}
