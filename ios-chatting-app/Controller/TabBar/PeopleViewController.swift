//
//  MainViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/04.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class PeopleViewController: UIViewController {
    
    var array: [UserModel] = [UserModel]()
    var tableView: UITableView?
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView?.delegate = self
        tableView?.dataSource = self
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints({ (make) in
            make.top.equalTo(view) //View에서 20만큼 떨어짐
            make.bottom.left.right.equalTo(view) //bottom, left, right을 view에다가 붙여줌
        })
        
        Database.database().reference().child("users").observe(DataEventType.value) { (snapshot) in
            
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            print(snapshot)
            
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let dictionary = fchild.value as! [String: Any]
                let userModel = UserModel()
                userModel.userName = dictionary[K.Firebase.UserDatabase.name] as? String
                userModel.profileImageUrl = dictionary[K.Firebase.UserDatabase.profileImageURL] as? String
                userModel.uid = dictionary[K.Firebase.UserDatabase.uid] as? String
                userModel.comment = dictionary["comment"] as? String
                
                if userModel.uid != myUid {
                    self.array.append(userModel)
                }
                
            }
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            
        }
        
        let selectFriendButton = UIButton()
        view.addSubview(selectFriendButton)
        selectFriendButton.snp.makeConstraints{(make) in
            make.bottom.equalTo(view).offset(-70)
            make.right.equalTo(view).offset(-20)
        }
        selectFriendButton.backgroundColor = UIColor.black
        selectFriendButton.addTarget(self, action: #selector(showSelectFriendController), for: .touchUpInside)
        
    }
    
    @objc func showSelectFriendController(){
        self.performSegue(withIdentifier: "SelectFriendSegue", sender: nil)
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
        let view = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        self.present(view, animated: true, completion: nil)
        
    }
    
}

extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let imageView = UIImageView()
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell) //cell 가운대로 주기
            make.left.equalTo(cell).offset(10) //cell left에 붙이기
            make.height.width.equalTo(50) //이미지 뷰의 크기
        }
        
        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { (data, response, error) in
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!);
                imageView.layer.cornerRadius = imageView.frame.size.width / 2
                imageView.clipsToBounds = true //테두리 만들기
            }
        }.resume()
        
        let label = UILabel()
        cell.addSubview(label)
        label.snp.makeConstraints{(make) in
            make.centerY.equalTo(cell) //cell의 가운데 정렬
            make.left.equalTo(imageView.snp.right).offset(20) //label의 left를 imageView right에다가 붙여주고 30만큼 떨어뜨림.
        }
        label.text = array[indexPath.row].userName
        
        cell.addSubview(label)
        
        let uiview_comment_background : UIView = UIView()
        let label_comment: UILabel! = UILabel()
        
        cell.addSubview(uiview_comment_background)
        cell.addSubview(label_comment)
        label_comment.textColor = UIColor(hex: "ffffff")
        
        label_comment.snp.makeConstraints { (make) in
            make.centerX.equalTo(uiview_comment_background)
            make.centerY.equalTo(uiview_comment_background)
        }
        if let comment = array[indexPath.row].comment {
            label_comment.text = comment
        }
    
        uiview_comment_background.backgroundColor = UIColor(hex: "9dba72")
        uiview_comment_background.snp.makeConstraints { (make) in
            make.right.equalTo(cell).offset(-10)
            make.centerY.equalTo(cell)
            if let count = label_comment.text?.count {
                make.width.equalTo(count * 10)
            } else {
                make.width.equalTo(0)
            }
            make.height.equalTo(30)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        view?.destinationUid = array[indexPath.row].uid
        
        //Navigation은 present 대신 push를 사용한다.
        self.navigationController?.pushViewController(view!, animated: true)
    }
    
}


