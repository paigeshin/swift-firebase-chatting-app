//
//  SignUpViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/01.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseRemoteConfig

class SignUpViewController: UIViewController {
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(view)
            make.height.equalTo(20)
        }
        
        //Remote Config를 이용해서 테마 변경
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        signUpButton.backgroundColor = UIColor(hex: color)
        cancelButton.backgroundColor = UIColor(hex: color)
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){(user, error) in
            let uid = user?.user.uid
            let image = self.imageView.image?.jpegData(compressionQuality: 0.1)
            let ref = Storage.storage().reference().child("userImages").child(uid!)
            
            ref.putData(image!, metadata: nil) { (data, error) in
                if(error == nil){
                    ref.downloadURL { (url, error) in
                        if let imageURLString = url?.absoluteString {
                            
                            let values = [
                                K.Firebase.UserDatabase.name: self.nameTextField.text!,
                                K.Firebase.UserDatabase.profileImageURL: imageURLString,
                                K.Firebase.UserDatabase.uid: Auth.auth().currentUser?.uid
                            ]
                            
                            Database.database().reference().child("users").child(uid!).setValue(values) { (error, dbRef) in
                                
                                if error == nil {
                                    
                                    let view = self.storyboard?.instantiateViewController(identifier: "MainViewTabBarController") as! UITabBarController
                                    self.present(view, animated: true, completion: nil)
                                    
                                }
                                
                            }

                        }
                    }
                }
            }
            
        }
    }
        
        
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

    
    
}
    
extension SignUpViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc func imagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
}
