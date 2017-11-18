@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
        try addMiddleWare()
        
        let chatAppController = ChatAppController()
        chatAppController.addRoutes(drop: self)
        let loginController = LoginController()
        loginController.addRoutes(drop: self)
        let groupController = GroupController()
        groupController.addRoutes(drop: self)
        let messageController = MessageController()
        messageController.addRoutes(drop: self)
        let chatUsers = ChatUserController()
        chatUsers.addRoutes(drop: self)
        let socketController = AppWebSocketsController()
        socketController.addSocket(drop: self)
        
        
        
    }
}
