@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
        
//        try addMiddleWare()
//        try addMiddleWarePassword()
        //try addMiddleWareAuth()
        
        let chatAppController = ChatAppController()
        chatAppController.addRoutes(drop: self)
        let groupController = GroupController()
        groupController.addRoutes(drop: self)
        let chatUsers = ChatUserController()
        chatUsers.addRoutes(drop: self)
        
        
        
        
    }
}
