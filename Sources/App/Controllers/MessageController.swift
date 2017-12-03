 import Vapor
 import HTTP
 import Fluent
 import Foundation
 import AuthProvider

 
 final class MessageController {
    var drop: Droplet? = nil
    var group: Group? = nil
    
    
    func addRoutes(drop: Droplet) {
        
        self.drop = drop
        //Web routes
        let basic = drop.grouped("messages")
        //basic.get(handler: index)
        basic.post(handler: create)
        basic.post(Group.parameter, "list", handler: indexView)
        
        
        //API routes
        let tokenMiddleWare = TokenAuthenticationMiddleware(ChatUser.self)
        let authed = drop.grouped(tokenMiddleWare)
        authed.get("api/messages/all", handler: allMessages)
        authed.get("api/messages/user-all-for-group", handler: allUserMessages)
        authed.post("api/messages/add-message", handler: writeMessage)
      
    }
    
    
    //MARK: - all routes for external API requests
    func allUserMessages(request: Request) throws -> ResponseRepresentable {
        
        let authedUser = try request.user()
        let groups = try authedUser.userGroups()
        
        let groupId = request.data["group_id"]?.string

        if let groupId = groupId {
        
            let group = try Group.groupFor(id: groupId)
            let mess = try group.messages.all()
            
            return try mess.makeJSON()
            
        } else {
            
            return "Not Found".makeResponse()

        }

        
    }
    
    func allMessages(request: Request) throws -> ResponseRepresentable {
   
        let allMessages = try Message.all()
        
        return try allMessages.makeJSON()
        
    }
    
    func writeMessage(request: Request) throws -> ResponseRepresentable {
        
        guard let text = request.data["text"]?.string , let groupId = request.data["group_id"]?.string else {
            throw Abort.badRequest
        }
        
        let user = try request.user()
        
        let groupToAddTo = try Group.groupFor(id: groupId)
        
        let newMessage = try Message.addMessage(text: text, group: groupToAddTo, user: user, userName: user.username, date: Date.init())
        
        do {
            return try newMessage.makeJSON()
            
        } catch {
            throw Abort.badRequest
        }
    }
    
    
    
    //MARK: - all routes for web app
    
    
    func indexView(request: Request) throws -> ResponseRepresentable {
        
        let user = request.auth.authenticated(ChatUser.self)
        
        if user != nil {
            
            
            if let group_param_id = request.parameters["group_id"]?.string {
                print("group_param_id: \(group_param_id)")
                
                let groupFromId = try Group.groupFor(name: group_param_id)
                self.group = groupFromId
     
                let user = request.auth.authenticated(ChatUser.self)
           
                var groupsMessages = try groupFromId.messages.all()
                
                for (i,_) in groupsMessages.enumerated() {
                    groupsMessages.insert(groupsMessages.remove(at:i),at:0)
                }
                
                
                let parameters = try Node(node: [
                    "currentgroup": groupFromId,
                    "messages": groupsMessages,
                    "authenticated": true,
                    "user": user!.makeNode(in: nil)
                    ])
                
                return try drop!.view.make("message", parameters)
           
            } else {
                print("no group_param_id")
                
            }
            
        }
    
        return Response(redirect: "/groups/list")
    }
    
    
    func create(request: Request) throws -> ResponseRepresentable {
        
        guard let text = request.data["text"]?.string else {
            throw Abort.badRequest
        }
        
        let user = request.auth.authenticated(ChatUser.self)
        let newMessage = try Message.addMessage(text: text, group: self.group, user: user, userName: (user?.username)!, date: Date.init())
        
        //let timeString: String = String.ini
        
        if user != nil {

            if let thisGroup = self.group {

                var groupsMessages = try thisGroup.messages.all()

                for (i,_) in groupsMessages.enumerated() {
                    groupsMessages.insert(groupsMessages.remove(at:i),at:0)
                }
                let parameters = try Node(node: [
                    "currentgroup": thisGroup,
                    "messages": groupsMessages,
                    "authenticated": true,
                    "user": user!.makeNode(in: nil)
                    ])

                return try drop!.view.make("message", parameters)
            } else {
                return Response(redirect: "/messages/list")
            }
        } else {
            return Response(redirect: "/chat/index")
        }

        
    }
    
   
 }
