//
//  ChatViewModel.swift
//  Gemini-AI
//
//  Created by Apple on 29/06/25.
//

import Foundation
import FirebaseAI
import Combine

protocol reloadData{
    func reload()
}

class ChatViewModel:ObservableObject {

    var delegate:reloadData?

    @Published private(set) var message:[Message] = [] {
        didSet {
            delegate?.reload()
        }
    }

    func sendmessage(promt:String){
        message.append(Message(message: promt, isUser: true))
        
        Task{
            let ai = FirebaseAI.firebaseAI(backend: .googleAI())
            let model = ai.generativeModel(modelName: "gemini-2.5-pro")
            do{
                // let response = try await model.generateContent(promt)
                let response = try model.generateContentStream(promt)

                DispatchQueue.main.async {
                    // Append an empty message for streaming output
                    self.message.append(Message(message: "", isUser: false))
                }

                for try await chunk in response {
                    if let part = chunk.text {
                        DispatchQueue.main.async {
                            if let lastIndex = self.message.lastIndex(where: { !$0.isUser }) {
                                var updatedMessages = self.message
                                var lastMessage = updatedMessages[lastIndex]
                                lastMessage.message += part
                                updatedMessages[lastIndex] = lastMessage
                                self.message = updatedMessages
                                self.delegate?.reload()
                            }
                        }
                    }
                }



//                let aiText = response.text
//                print("response :\(aiText!)")
//                DispatchQueue.main.async {
//                    self.message
//                        .append(Message(message: aiText ?? "NO result", isUser: false))
//                }

            }catch let err {
                DispatchQueue.main.async {
                    self.message.append(Message(message: "Error: \(err.localizedDescription)", isUser: false))
                }
            }
        }

    }
}

