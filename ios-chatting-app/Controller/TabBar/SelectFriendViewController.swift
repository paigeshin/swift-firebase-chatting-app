//
//  SelectFriendViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/14.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox

class SelectFriendViewController: UIViewController, BEMCheckBoxDelegate{
    
    var users = Dictionary<String, Bool>() //초대할 친구들
    @IBOutlet weak var tableView: UITableView!
    var array: [UserModel] = [UserModel]()
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadUsers()
        
        
        
    }
    
    func createRoom(){
        
        let myUid = Auth.auth().currentUser?.uid
        users[myUid!] = true
        let nsDic = users as! NSDictionary
        print(users)
        
        //초대할 친구들을 담은 array를 db에 추가시켜줌
        Database.database().reference().child("chatrooms").childByAutoId().child("users").setValue(nsDic)
        
    }
    
    @IBAction func createRommButtonPressed(_ sender: UIButton) {
        createRoom()
    }
    
    
    func loadUsers(){
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
                print(self.array.count)
            }
            
        }
    }
    
}



extension SelectFriendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        cell.labelName.text = array[indexPath.row].userName
        
        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { (data, response, error) in
            DispatchQueue.main.async {
                cell.imageViewProfile!.image = UIImage(data: data!);
                cell.imageViewProfile!.layer.cornerRadius = cell.imageViewProfile!.frame.size.width / 2
                cell.imageViewProfile!.clipsToBounds = true //테두리 만들기
            }
        }.resume()
        //checkbox delegate 추가
        cell.checkboxFriend.delegate = self //tableView Cell 이 delegate를 받음
        cell.checkboxFriend.tag = indexPath.row
        return cell
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        if(checkBox.on) {
            users[array[checkBox.tag].uid!] = true
        } else {
            users.removeValue(forKey: array[checkBox.tag].uid!)
        }
        print(users)
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

class SelectFriendCell : UITableViewCell {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var checkboxFriend: BEMCheckBox!
    
}
