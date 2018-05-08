//
//  ChatViewController.swift
//  Family Chat
//
//  Created by Jerry Ding on 2018-05-07.
//  Copyright © 2018 Jerry Ding. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var messageArray : [Message] = [Message]()
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        messageTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        
        retrieveMessages()
        
        messageTableView.separatorStyle = .none

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.avatarImageView.image = UIImage(named: "egg")
        cell.senderNicknameLabel.text = messageArray[indexPath.row].senderNickname
        cell.messageBodyLabel.text = messageArray[indexPath.row].messageBody
        
        if messageArray[indexPath.row].senderID == Auth.auth().currentUser?.uid as String? {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            heightConstraint.constant = keyboardSize.height + 50
            view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        heightConstraint.constant = 50
        view.layoutIfNeeded()
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 100.0
    }
    
    func retrieveMessages() {
        
        let DB = Database.database().reference()
        
        DB.child("Messages").observe(.childAdded) { (messageSnapshot) in
            
            let messageSnapshotValue = messageSnapshot.value as! Dictionary<String,String>
            let message = Message()
            message.senderID = messageSnapshotValue["SenderID"]!
            message.messageBody = messageSnapshotValue["MessageBody"]!
            
            DB.child("Nicknames").observeSingleEvent(of: .value, with: { (userSnapshot) in
                
                let userSnapshotValue = userSnapshot.value as! Dictionary<String,String>
                message.senderNickname = userSnapshotValue[message.senderID]!
                
                self.messageArray.append(message)
                self.configureTableView()
                self.messageTableView.reloadData()
                self.messageTableView.scrollToRow(at: IndexPath(item: self.messageArray.count - 1, section: 0), at: .bottom, animated: true)
                
            })
            
        }
        
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        messageTextField.endEditing(true)
        
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let senderID = Auth.auth().currentUser?.uid
        let messageBody = messageTextField.text!
        
        let messageDictionary = ["SenderID" : senderID, "MessageBody" : messageBody]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            }
            else {
                print("Message Saved")
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
            }
        }
        
    }
    
}
