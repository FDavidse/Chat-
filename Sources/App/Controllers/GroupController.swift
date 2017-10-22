import Vapor
import HTTP
import Fluent


final class GroupController {
    var drop: Droplet? = nil

    func addRoutes(drop: Droplet) {
        
        self.drop = drop

        let basic = drop.grouped("groups")
        //basic.get(handler: index)
        basic.get("list", handler: indexView)
        basic.post(handler: create)
        basic.post("createNewGroup", handler: createNewGroup)
        basic.post("delete", Group.parameter, handler: deleteGroup)
        //basic.delete(Group.self, handler: delete)
        basic.post(Group.parameter, "joingroup", handler: joinGroupView)
        basic.post(Group.parameter, "leavegroup", handler: leaveGroupView)
    }
    
//    func index(request: Request) throws -> ResponseRepresentable {
//        //return try JSON(node: Group.all().makeNode())
//    }
    
    func indexView(request: Request) throws -> ResponseRepresentable {
        
        let user = request.auth.authenticated(ChatUser.self)
        
        var joinedGroups : [Group] = []
        
        if let j = try user?.groups.all() {
            joinedGroups = j
            for group in joinedGroups {
                print("name of joined group: \(group.name)")
            }
        }
        
        if user != nil {
            
            let allGroups : [Group]? = try Group.all()
            var groupIds : [Int] = []
            
            var groups: [Group]? = []
            if let user = user {
                groups = try user.userGroups()
            }
            var notJoinedGroups: [Group]? = []
            var joined: [Bool] = []
            if groups != nil {
                
                for group in allGroups! {
                    var allreadyJoined = false
                    for usergroup in groups! {
                        if group.id == usergroup.id {
                            //contained in both
                            allreadyJoined = true
                            joined.append(allreadyJoined)
                        }
                    }
                    if !allreadyJoined {
                        notJoinedGroups?.append(group)
                    }
                    groupIds.append((group.id?.int)!)
                    
                }
            }
            
            let allGroupsNode = try allGroups!.makeNode(in: nil)
            let userGroupsNode = try groups!.makeNode(in: nil)
            let notJoinedGroupsNode = try notJoinedGroups!.makeNode(in: nil)
            var loggedIn: Bool = true
            if user == nil {
                loggedIn = false
            }
            
            
            
            let parameters = try Node(node: [
                "allGroups": allGroupsNode,
                "userGroups": userGroupsNode,
                "allreadyJoinedGroup": joinedGroups.makeNode(in: nil),
                "notJoinedGroups": notJoinedGroupsNode,
                "authenticated": loggedIn,
                "user": user!.makeNode(in: nil),
                "groupIds": groupIds
                ])
            
            return try drop!.view.make("group", parameters)
            
        }else {
            return Response(redirect: "/chat/login")
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        
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

extension Request {
    func group() throws -> Group {
        guard let json = json else { throw Abort.badRequest }
        return try Group(node: Node(json))
    }
}
