//
//  ViewController.swift
//  Gemini-AI
//
//  Created by Apple on 29/06/25.
//

import UIKit
import FirebaseAI

class ChatVC: UIViewController  {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtPromot:UITextField!
    @IBOutlet weak var tblChat:UITableView!
    private var vm = ChatViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        txtPromot.text = "Write a story about a magic backpack."
        self.tblChat.delegate = self
        self.tblChat.dataSource = self
        vm.delegate = self
//        self.tblChat.separatorStyle = .none
        self.tblChat.register(UITableViewCell.self, forCellReuseIdentifier: "UserMessageCell")
        self.tblChat.register(UITableViewCell.self, forCellReuseIdentifier: "GeminiMessageCell")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = -keyboardFrame.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = 0
        }
    }

    func scrollBottom() {
        if vm.message.count > 0 {
            let indexPath = IndexPath(row: vm.message.count - 1, section: 0)
            tblChat.scrollToRow(at: indexPath, at: .bottom, animated: true)
          }
    }

    @IBAction func generateAI(){
        guard let prompt = txtPromot.text, !prompt.isEmpty else { return }
        vm.sendmessage(promt: prompt)
    }
}

extension ChatVC:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.message.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = vm.message[indexPath.row]
        if message.isUser {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageCell", for: indexPath)
            cell.textLabel?.text = ("You: \(message.message)")
            cell.textLabel?.textAlignment = message.isUser ? .right : .left
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeminiMessageCell", for: indexPath)
            cell.textLabel?.text = ("Gemini: \(message.message)")
            cell.textLabel?.numberOfLines = 0
            return cell
        }
    }
}

extension ChatVC:reloadData {
    func reload() {
        self.tblChat.reloadData()
        scrollBottom()
    }
}
