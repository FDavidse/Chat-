import FluentProvider
import PostgreSQLProvider
import AuthProvider
import VaporValidation
import LeafProvider
import HTTP
import Sessions

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        try setupMiddleware()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
        try addProvider(VaporValidation.Provider.self)
        try addProvider(LeafProvider.Provider.self)

    }
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(ChatUser.self)
        preparations.append(Group.self)
        preparations.append(Message.self)
        preparations.append(Post.self)
        preparations.append(Token.self)
    }
    
    private func setupMiddleware() throws {
        
        
        let memory = MemorySessions()
        let sessionsMiddleware = SessionsMiddleware(memory)
        let persistMiddleware = PersistMiddleware(ChatUser.self)
        let passwordMiddleware = PasswordAuthenticationMiddleware(ChatUser.self)
        
        //let authed = drop.grouped([sessionsMiddleware, persistMiddleware, passwordMiddleware])
        self.addConfigurable(middleware: sessionsMiddleware, name: "session")
        self.addConfigurable(middleware: persistMiddleware, name: "persist")
        self.addConfigurable(middleware: passwordMiddleware, name: "password")

        
        //try self.resolveSessions()
        
    
    }

}
