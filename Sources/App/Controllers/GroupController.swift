import Vapor
import HTTP
import Fluent
import AuthProvider


final class GroupController {
    var drop: Droplet? = nil

    func addRoutes(drop: Droplet) {
        
        self.drop = drop

        //Web app routes
        let basic = drop.grouped("groups")
        //basic.get(handler: index)
        basic.get("list", handler: indexView)
        basic.post(handler: create)
        basic.post("createNewGroup", handler: createNewGroup)
        basic.post("delete", Group.parameter, handler: deleteGroupView)
        //basic.delete(Group.self, handler: delete)
        basic.post(Group.parameter, "joingroup", handler: joinGroupView)
        basic.post(Group.parameter, "leavegroup", handler: leaveGroupView)
        
        //API routes
        let tokenMiddleWare = TokenAuthenticationMiddleware(ChatUser.self)
        let authed = drop.grouped(tokenMiddleWare)
        authed.get("api/groups/user-all", handler: allUserGroups)
        authed.get("api/groups/all", handler: allGroups)
        authed.post("api/groups/add-group", handler: insertNewGroup)
        authed.post("api/groups/join-group", handler: joinGroup)
        authed.post("api/groups/leave-group", handler: leaveGroup)
        authed.post("api/groups/delete-group", handler: deleteGroup)

    }

    //MARK: - all routes for external API requests
    func allUserGroups(request: Request) throws -> ResponseRepresentable {
        
        let authedUser = try request.user()
        let groups = try authedUser.groups.all()
        
        return try groups.makeJSON()
        
    }
    
    func allGroups(request: Request) throws -> ResponseRepresentable {
        
        let groups = try Group.all()
        
        return try groups.makeJSON()
        
    }
    
    func insertNewGroup(request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.data["name"]?.string else {
            throw Abort.badRequest
        }
        
        let newGroup = try Group.addGroup(name: name)
        
        return try newGroup.makeJSON()
        
    }
    
    func joinGroup(request: Request) throws -> ResponseRepresentable {

        if let group_param_id = request.data["group_id"]?.string {

            let groupFromId = try Group.groupFor(id: group_param_id)

            let authedUser = try request.user()
            let attached = try authedUser.groups.isAttached(groupFromId)
            if attached == true {
                //already member of group
                return Response(status: .notFound)
            } else {
                //add it
                try authedUser.groups.add(groupFromId)
                return try groupFromId.makeJSON()
            }
            
            
        } else {
            print("no group_param_id")
            throw Abort.badRequest
        }
        
    }
    
    func leaveGroup(request: Request) throws -> ResponseRepresentable {
        
        if let group_param_id = request.data["group_id"]?.string {
            print("group_param_id: \(group_param_id)")
            
            let groupFromId = try Group.groupFor(id: group_param_id)
            
            print("group to leave has name: \(groupFromId.name) and id: \(groupFromId.id ?? "1000")")
            let user = try request.user()
            
            do {
                try user.groups.remove(groupFromId)
                return try groupFromId.makeJSON()
            } catch {
                return Response(status: .notFound)
            }
            
            
        } else {
            print("no group_param_id")
            throw Abort.badRequest
        }
      
    }
    
    func deleteGroup(request: Request) throws -> ResponseRepresentable {
        if let group_param_id = request.data["group_id"]?.string {
            print("group_param_id: \(group_param_id)")
            
            let groupFromId = try Group.groupFor(id: group_param_id)
           
            do {
                try groupFromId.delete()
                return try groupFromId.makeJSON()
            } catch {
                return Response(status: .notFound)
            }
            
            
        } else {
            print("no group_param_id")
            throw Abort.badRequest
        }
        
    }

    
    //MARK: - all routes for web app
    
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
    
              
        let params = request.parameters
        
        if let group_param_id = request.parameters["group_id"]?.string {
            
            let groupFromId = try Group.groupFor(name: group_param_id)

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
    
    func deleteGroupView(request: Request) throws -> ResponseRepresentable {
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
