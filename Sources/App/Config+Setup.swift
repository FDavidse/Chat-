import FluentProvider
import PostgreSQLProvider
import AuthProvider
import VaporValidation
import LeafProvider


extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
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
}
