import Vapor
import HTTP
import Fluent
import Foundation

let messageReceived            = "messageReceived"
let messageReceivedFromIOS     = "messageReceivedFromIOS "

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
                    drop.console.wait(seconds: 5) // every 5 seconds
                }
            }
            
            ws.onText = { ws, text in
                print("Text received: \(text)")
                
//                NotificationCenter.default.post(name: Notification.Name(messageReceived), object: nil)

                
                let json = try JSON(bytes: Array(text.utf8))
                
                
                if let u = json.object?["userName"]?.string {
                    username = u
                    self.room.connections[u] = ws
                    try self.room.bot("\(u) has joined. 👋")
                } else{
                    username = "new user"
                    self.room.connections[username!] = ws
                    //try self.room.bot("\(String(describing: username)) has joined. 👋")
                }
                
                if let u = username, let m = json.object?["message"]?.string {
                    try self.room.send(name: u, message: m)
                }
                
                
                
                //reverse the characters and send back
                let rev = String(text.characters.reversed())
                //try ws.send(rev)
            }
            
            ws.onClose = { ws, code, reason, clean in
                print("Closed. reason being \(reason ??  "")")
                guard let user = username else { return }
                self.room.connections.removeValue(forKey: user)
            }
        }
        
        
    }
    
    
    
}

