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
        
        let basic = drop.grouped("messages")
        //basic.get(handler: index)
        basic.post(handler: create)
        basic.post(Group.parameter, "list", handler: indexView)
        basic.post(Group.parameter, "addMessage", handler: createMessage)
        basic.post("createNewGroup", handler: createNewGroup)
        
        //basic.delete(Group.self, handler: delete)
        basic.post(Group.parameter, "joingroup", handler: joinGroupView)
        
        
        
        let tokenMiddleWare = TokenAuthenticationMiddleware(ChatUser.self)
        let authed = drop.grouped(tokenMiddleWare)
        authed.get("messages/all", handler: allMessages)
        authed.get("messages/user-all-for-group", handler: allUserMessages)

        
        
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
    
    
    
    func createMessage(request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.data["name"]?.string else {
            throw Abort.badRequest
        }
        
        let newGroup = try Group.addGroup(name: name)
        
        return Response(redirect: "/groups/list")
        //    return group
    }
    
    func createNewGroup(request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.data["name"]?.string else {
            throw Abort.badRequest
        }
        
        _ = try Group.addGroup(name: name)
        
        return Response(redirect: "/groups/list")
        //    return group
    }
    
    func joinGroupView(request: Request) throws -> ResponseRepresentable {
        
        //        var pivot = try Pivot<ChatUser, Group>(chatuser, group)
        //        try pivot.save()
        //return tiluser
        
        
        let params = request.parameters
        
        if let group_param_id = request.parameters["group_id"]?.string {
            print("group_param_id: \(group_param_id)")
            //let joinedGroup = Group.groupFor(group_param_id)
            
            let groupFromId = try Group.groupFor(name: group_param_id)
            
            print("group to join has name: \(groupFromId.name) and id: \(groupFromId.id ?? "1000")")
            
            let user = request.auth.authenticated(ChatUser.self)
            if let attached = try user?.groups.isAttached(groupFromId) {
                if attached {
                    //already member of group
                } else {
                    //add it
                    try user?.groups.add(groupFromId)
                }
            } else {
                //problem getting attached info
            }
            
            
            
            
            
            
            
        } else {
            print("no group_param_id")
            
        }
        
        
        
        return Response(redirect: "/groups/list")
    }
    
    func leaveGroupView(request: Request) throws -> ResponseRepresentable {
        
        if let group_param_id = request.parameters["group_id"]?.string {
            print("group_param_id: \(group_param_id)")
            
            let groupFromId = try Group.groupFor(name: group_param_id)
            
            print("group to join has name: \(groupFromId.name) and id: \(groupFromId.id ?? "1000")")
            
            let user = request.auth.authenticated(ChatUser.self)
            
            try user?.groups.remove(groupFromId)
            
            
            
        } else {
            print("no group_param_id")
            
        }
        
        
        
        return Response(redirect: "/groups/list")
    }
    
    
    
    func delete(request: Request, group: Group) throws -> ResponseRepresentable {
        try group.delete()
        return JSON([:])
    }
    
    func deleteGroup(request: Request) throws -> ResponseRepresentable {
        //try group.delete()
        return Response(redirect: "/groups/list")
    }
 }
