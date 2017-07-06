import Vapor
import HTTP
import Fluent

final class ChatUserController {
    
    func addRoutes(drop: Droplet) {
        let basic = drop.grouped("users")
        basic.get(handler: index)
        basic.post(handler: create)
        basic.delete("delete", ChatUser.parameter, handler: delete)
//        basic.get(ChatUser.self, "acronyms", handler: acronymsIndex)
//        basic.post(ChatUser.self, "join", Group.self, handler: joinGroup)
//        basic.get(ChatUser.self, "groups", handler: groupsIndex)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {

        let users = try ChatUser.all()
        
        //let usersNodes = try users.makeNode(in: nil)
        
        
        //return try JSON(node: ChatUser.all().makeNode(in: nil))
        
        //return try users.makeJSON()
        
        //return try JSON(node: ChatUser.all().makeNode(in: nil))
        return try users.makeJSON()
        
       // return users as! ResponseRepresentable
        
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        
        var ChatUser = try request.chatuser()
        try ChatUser.save()
        return ChatUser
    }
    
    func delete(request: Request) throws -> ResponseRepresentable {
        //try ChatUser.delete()
        let user = try request.parameters.next(ChatUser.self)
        try user.delete()
        
        return JSON([:])
    }
    
//    func acronymsIndex(request: Request, ChatUser: ChatUser) throws -> ResponseRepresentable {
//        let children = try ChatUser.acronyms()
//        return try JSON(node: children.makeNode())
//    }
    
//    func joinGroup(request: Request, ChatUser: ChatUser, group: Group) throws -> ResponseRepresentable {
//        var pivot = Pivot<ChatUser, Group>(ChatUser, group)
//        try pivot.save()
//        return ChatUser
//    }
//    
//    func groupsIndex(request: Request, ChatUser: ChatUser) throws -> ResponseRepresentable {
//        let groups = try ChatUser.groups()
//        return try JSON (node: groups.makeNode())
//    }
    
}



extension Request {
    func chatuser() throws -> ChatUser {
        guard let json = json else { throw Abort.badRequest }
        
        return try ChatUser(json: json);
        
        
    }
}
