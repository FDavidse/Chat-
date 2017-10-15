 import Vapor
import HTTP
import Fluent


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







    }
    
    
    func indexView(request: Request) throws -> ResponseRepresentable {
        
        let user = request.auth.authenticated(ChatUser.self)
        
        if user != nil {
        
        //http://0.0.0.0:8080/messages/test/list
            //http://0.0.0.0:8080/messages/test/list
            //http://0.0.0.0:8080/messages/test/list
        if let group_param_id = request.parameters["group_id"]?.string {
            print("group_param_id: \(group_param_id)")
            
            let groupFromId = try Group.groupFor(name: group_param_id)
            self.group = groupFromId
            
            print("group to join has name: \(groupFromId.name) and id: \(groupFromId.id ?? "1000")")
            
            let user = request.auth.authenticated(ChatUser.self)
            
            
            let groupsMessages = try groupFromId.messages.all()
            
            
            
            
            let parameters = try Node(node: [
                "messages": groupsMessages,
                "authenticated": true,
                "user": user!.makeNode(in: nil)
                ])
            
            return try drop!.view.make("message", parameters)
            
            //return Response(redirect: "/messages/test/list")
            
            
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
        
        let newMessage = try Message.addMessage(text: text, group: self.group)
        let user = request.auth.authenticated(ChatUser.self)
        
        if user != nil {
        
        if let thisGroup = self.group {
        
        let groupsMessages = try thisGroup.messages.all()
      
        let parameters = try Node(node: [
            "messages": groupsMessages,
            "authenticated": true,
            "user": user!.makeNode(in: nil)
            ])
        
        return try drop!.view.make("message", parameters)
        } else {
            return Response(redirect: "/messages")
        }
        } else {
            return Response(redirect: "/chat/index")
        }
        
        //return Response(redirect: redirectString)
        
        //return Response(redirect: "/messages")
        //    return group
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
