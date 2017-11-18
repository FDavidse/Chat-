import Vapor
import HTTP
import Fluent
import Foundation

final class AppWebSocketsController {
    
    let room = Room()
    
    func addSocket(drop: Droplet) {
        drop.socket("ws") { req, ws in
            print("New WebSocket connected: \(ws)")
            var username: String? = nil
            
            // ping the socket to keep it open
            try background {
                while ws.state == .open {
                    try? ws.ping()
                    drop.console.wait(seconds: 10) // every 10 seconds
                }
            }
            
            ws.onText = { ws, text in
                print("Text received: \(text)")
                
                let json = try JSON(bytes: Array(text.utf8))
                
                
                print("json !")
                
                if let u = json.object?["username"]?.string {
                    username = u
                    self.room.connections[u] = ws
                    try self.room.bot("\(u) has joined. 👋")
                } else{
                    username = "filip"
                    self.room.connections[username!] = ws
                    try self.room.bot("\(String(describing: username)) has joined. 👋")
                }
                
                if let u = username, let m = json.object?["message"]?.string {
                    try self.room.send(name: u, message: m)
                }
                
                
                
                //reverse the characters and send back
                let rev = String(text.characters.reversed())
                try ws.send(rev)
            }
            
            ws.onClose = { ws, code, reason, clean in
                print("Closed.")
            }
        }
        
        
    }
    
    
    
}

