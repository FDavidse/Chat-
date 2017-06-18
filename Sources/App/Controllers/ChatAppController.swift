import Vapor
import HTTP


final class ChatAppController {
    
    var wrongLogin: Bool = false
    
    
    func addRoutes(drop: Droplet) {
        let til = drop.grouped("til")
        til.get(handler: indexView)
        til.post(handler: addAcronym)
        til.get("register", handler: registerView)
        til.post("register", handler: register)
        til.get("login", handler: loginView)
        til.post("login", handler: login)
        til.get("logout", handler: logout)
        
    }
    
    func indexView(request: Request) throws -> ResponseRepresentable {
        
        let user = try? request.auth.user() as! ChatUser
        
        if let user = user {
            self.wrongLogin = false
        }
        
        let parameters = try Node(node: [
            "authenticated": user != nil,
            "user": user?.makeNode(),
            "wrongpassword": self.wrongLogin
            ])
        return try drop.view.make("index", parameters)
    }
    
    func addAcronym(request: Request) throws -> ResponseRepresentable {
        
        guard let short = request.data["short"]?.string, let long = request.data["long"]?.string else {
            throw Abort.badRequest
        }
        
        let user = try request.auth.user() as! TILUser
        
        var acronym = Acronym(short: short, long: long, tiluserId: user.id)
        try acronym.save()
        
        return Response(redirect: "/til")
    }
    
    func deleteAcronym(request: Request, acronym: Acronym) throws -> ResponseRepresentable {
        try acronym.delete()
        return Response(redirect: "/til")
    }
    
    func registerView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("register")
    }
    
    func register(request: Request) throws -> ResponseRepresentable {
        
        guard let email = request.formURLEncoded?["email"]?.string,
            let password = request.formURLEncoded?["password"]?.string,
            let name = request.formURLEncoded?["name"]?.string else {
                return "Missing email, password, or name"
        }
        _ = try TILUser.register(name: name, email: email, rawPassword: password)
        
        let credentials = UsernamePassword(username: email, password: password)
        try request.auth.login(credentials)
        
        return Response(redirect: "/til")
        
    }
    
    func loginView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login")
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        guard let email = request.formURLEncoded?["email"]?.string,
            let password = request.formURLEncoded?["password"]?.string  else {
                //return "Missing email or password"
                self.wrongLogin = true
                return Response(redirect: "/til")
                
        }
        let credential = UsernamePassword(username: email, password: password)
        do {
            try request.auth.login(credential)
            return Response(redirect: "/til")
        } catch let e as TurnstileError {
            //return e.description
            self.wrongLogin = true
            return Response(redirect: "/til")
            
        }
        
        
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/til")
    }
    
    
}
