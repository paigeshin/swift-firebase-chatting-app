//
//  ViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/01.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseRemoteConfig

class ViewController: UIViewController {

    var box = UIImageView()
    var remoteConfig: RemoteConfig!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Remote Config
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings()
        remoteConfig.configSettings = remoteConfigSettings
        remoteConfig.setDefaults(fromPlist: "RemoteConfig")
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(3600)) { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            self.remoteConfig.activate(completionHandler: { (error) in
              // ...
            })
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
          self.displayWelcome()
        }
        
    
        //View
        self.view.addSubview(box)
        box.snp.makeConstraints{(make) in
            make.center.equalTo(self.view)
        }
        box.image = #imageLiteral(resourceName: "icon")

    }
    
    func displayWelcome(){
        
        guard let color = remoteConfig["splash_background"].stringValue else { fatalError("Error fetching color value") }
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
    
        if(caps) {
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default) { (action) in
                exit(0)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            //다음 화면으로 넘기기.
            let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            self.present(loginVC, animated: false, completion: nil)
            
        }
        self.view.backgroundColor = UIColor(hex: color)
        
    }


}


extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)

        //UIColor hex code 값으로 주기
        scanner.scanLocation = 1

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
