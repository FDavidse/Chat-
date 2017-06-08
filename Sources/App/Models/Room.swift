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
            guard username != name else {
                continue
            }
            
            try socket.send(str)
        }
    }

    
    init() {
        connections = [:]
    }
}
