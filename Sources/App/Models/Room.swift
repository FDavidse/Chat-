//
//  Room.swift
//  ChatServerProject
//
//  Created by Filip Davidse on 03-06-17.
//
//

import Vapor
import FluentProvider
import HTTP
import Foundation

class Room {
    var connections: [String: WebSocket]
    
    func bot(_ message: String) throws {
        try send(name: "Bot", message: message)
    }
    
    func send(name: String, message: String) throws {
        //let message = message.truncated(to: 256)
        
        let json = try JSON(node: [
            "username": name,
            "message": message
            ])
        
        let str = String(describing: json)
        
        
        for (username, socket) in connections {
//            guard username != name else {
//                continue
//            }
            
            try socket.send(str)
        }
    }

    
    init() {
        connections = [:]
         NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name(messageReceived), object: nil)
        
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        
        do {
            try send(name: "chat app", message: "new messages received")
        } catch {
            print("failure sending based on notification")
        }
    }
}
