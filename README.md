# swift-firebase-chatting-app ios chatting app

🔵 HexColor UIColor(hex: "#352342") 식으로 사용하기

        extension UIColor {
            convenience init(hex: String) {
                let scanner = Scanner(string: hex)
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

        let color = UIColor(hex: "ff0000")
        
🔵 Storyboard를 토대로 화면 넘기기

        //다음 화면으로 넘기기.
        let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        self.present(loginVC, animated: false, completion: nil)
