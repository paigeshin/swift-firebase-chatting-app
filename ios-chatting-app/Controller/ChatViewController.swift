//
//  ChatViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/04.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth



class ChatViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textFieldMessage: UITextField!
    
    @IBOutlet weak var bottomConstraintOutlet: NSLayoutConstraint!
    
    var uid : String?
    var chatRoomUid : String?
    public var destinationUid: String? // 나중에 내가 채팅할 대상의 uid
    
    var comments = [ChatModel.Comment]()
    var userModel: UserModel? //Destionation UserModel
    
    var databaseRef: DatabaseReference?
    var observe: UInt?
    var peopleCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.delegate = self
        tableView.dataSource = self 
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
        self.tabBarController?.tabBar.isHidden = true //텝바 안보여주기
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    //시작
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification: )), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification: )), name: UIResponder.keyboardWillHideNotification, object: nil);
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //observer 지워주기
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false //화면 나갈 때 다시 보여줌
        databaseRef?.removeObserver(withHandle: observe!)
    }
    
    
    
    //키보드 보여주기
    @objc func keyboardWillShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraintOutlet.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded() //레이아웃 그려주기
        }) { (complete) in
            
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
            
        }
        
    }
    
    //키보드 숨겨주기
    @objc func keyboardWillHide(notification: Notification){
        self.bottomConstraintOutlet.constant = 20
        self.view.layoutIfNeeded() //레이아웃 그려주기
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func createRoom(){
        let createRoomInfo: Dictionary<String, Any> = [
            "users" : [
                uid: true,
                destinationUid: true
            ]
        ]
        
        //방이 존재하는지 확인
        if chatRoomUid == nil{
            self.sendButton.isEnabled = false
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo) { (error, dbRef) in
                if error == nil {
                    self.checkChatRoom()
                }
            }
        } else {
            //메세지 넣어주기.
            let value : Dictionary<String, Any> = [
                "uid": uid!,
                "message": textFieldMessage.text!,
                "timestamp": ServerValue.timestamp(), //firebase default value
                "readUsers": [uid! : true]
            ]
            
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value) { (error, dbRef) in
                self.textFieldMessage.text = ""
                
            }
            
        }
        
        
    }
    
    /*
     요약.
     1. uid를 기준으로 모든 chatroom을 가져온다.
     2. destionation uid와 비교해서 이미 있는 채팅방인지 아닌지 확인.
     */
    func checkChatRoom(){
        
        //먼저 chatroom을 다 찾고 users uid가 있는지 찾는다.
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true)
            .observeSingleEvent(of: DataEventType.value) { (snapshot) in
                
                //uid가 있는 기준으로 챗방을 모두 가져옴
                for item in snapshot.children.allObjects as! [DataSnapshot]{
                    
                    //그 채팅방에 destionation uid도 존재하는지 비교함.
                    if let chatRoomdic = item.value as? [String: AnyObject]{
                        
                        let chatModel = ChatModel(JSON: chatRoomdic) //json으로 값을 받아옴.
                        
                        if chatModel!.users[self.destinationUid!] != nil {
                            
                            if chatModel!.users[self.destinationUid!]! {
                                self.chatRoomUid = item.key
                                self.sendButton.isEnabled = true
                                self.getDestinationInfo() //메시지 가져오기
                            }
                            
                        }
                        
                    }
                }
        }
    }
    
    func getDestinationInfo(){
        
        //상대 채팅방 유저의 uid 값을 가져온다.
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            let fchild = snapshot
            let dictionary = fchild.value as! [String: Any]
            self.userModel = UserModel()
            self.userModel?.profileImageUrl = dictionary[K.Firebase.UserDatabase.profileImageURL] as? String
            self.userModel?.uid = dictionary[K.Firebase.UserDatabase.uid] as? String
            self.userModel?.userName = dictionary[K.Firebase.UserDatabase.name] as? String
            self.getMessageList()
        }
        
    }
    
    func getMessageList() {
        
        databaseRef = Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments")
        
        observe = databaseRef?.observe(DataEventType.value, with: { (snapshot) in
            self.comments.removeAll()
            
            var readUserDic: Dictionary<String, AnyObject> = [:]
            
            print("snapshot: \(snapshot)")
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let key = item.key as String
                
                let comment = ChatModel.Comment(JSON: item.value as! [String : AnyObject]) //일단 값을 집어 넣을 comment
                let comment_modify = ChatModel.Comment(JSON: item.value as! [String : AnyObject]) //비교해줄 comment, 이 값을 토대로 update 시켜줌
                comment_modify?.readUsers[self.uid!] = true
                readUserDic[key] = comment_modify?.toJSON() as! NSDictionary //Firebase가 NSDictionary만 지원한다.
                print("readUserDic: \(readUserDic[key])" )
                self.comments.append(comment!)
            }
            
            if self.comments.count > 0 {
                let nsDic = readUserDic as NSDictionary
                
                //유저의 커멘트가 uid를 가지고 있다면 업데이트 시킨다. 예전에는 uid가 있던 없던간에 다 update 시켜버림
                snapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: {(error, reference) in
                    
                    print("Updated Value : \(reference)")
                    
                    self.tableView.reloadData()
                    
                    if self.comments.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                })
                
            }
            
            
            
            
        })
        
        
        
    }
    
    func setReadCount(label: UILabel?, position: Int?){
        let readCounter = self.comments[position!].readUsers.count //db에서 불러온 값
        
        //People count가 nil일 때만 값을 불러옴. - 서버 과부하를 막아줌. (읽은 사람)
        if(peopleCount == nil){
            
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("users").observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
                
                let dictionary = snapshot.value as! [String: Any]
                self.peopleCount = dictionary.count
                let noReadCount = self.peopleCount! - readCounter //전체 db dictionary count - db에서 불러온 값의 유저 count
                
                if(noReadCount > 0){
                    label?.isHidden = false
                    label!.text = String(noReadCount)
                } else {
                    label?.isHidden = true
                }
                
            })
            
            //People count가 nil이 아니면 그냥 연산만 해준다.
        } else {
            
            let noReadCount = peopleCount! - readCounter //전체 db dictionary count - db에서 불러온 값의 유저 count
            
            if(noReadCount > 0){
                label?.isHidden = false
                label!.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
            
        }
        
    }
}


extension ChatViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //말풍선 적용
        if self.comments[indexPath.row].uid == uid {
            let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.labelMessage!.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0 //여러줄로 나눠줄 수 있음
            
            if let time: Int = self.comments[indexPath.row].timestamp {
                print(time)
                view.myTimestamp.text = time.toDayTime
            }
            
            setReadCount(label: view.labelReadCounter, position: indexPath.row)
            
            return view
        } else {
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.labelName.text = userModel?.userName
            view.labelMessage.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0 //여러줄로 나눠줄 수 있음
            
            if let time: Int = self.comments[indexPath.row].timestamp {
                view.destinationTimestamp.text = time.toDayTime
            }
            
            let url = URL(string: self.userModel!.profileImageUrl!)
            
            
            URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                DispatchQueue.main.async {
                    if let imageData = data {
                        view.imageViewProfile!.image = UIImage(data: imageData)
                    }
                    
                    view.imageViewProfile?.layer.cornerRadius = view.imageViewProfile.frame.width / 2
                    view.imageViewProfile.clipsToBounds = true
                }
            }).resume()
            
            setReadCount(label: view.destinationLabelReadCounter, position: indexPath.row)
            
            return view
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

class MyMessageCell : UITableViewCell {
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var myTimestamp: UILabel!
    @IBOutlet weak var labelReadCounter: UILabel!
    
    
}

class DestinationMessageCell : UITableViewCell {
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var destinationTimestamp: UILabel!
    @IBOutlet weak var destinationLabelReadCounter: UILabel!
    
    
}

extension Int {
    
    var toDayTime : String {
        let dataFormatter = DateFormatter()
        dataFormatter.locale = Locale(identifier: "ko_KR")
        dataFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self) / 1000)
        return dataFormatter.string(from: date)
    }
    
}

