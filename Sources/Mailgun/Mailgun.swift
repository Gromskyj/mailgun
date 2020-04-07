import Vapor
import Foundation

// MARK: - Service
public protocol MailgunProvider {
    func send(_ content: MailgunMessage) -> EventLoopFuture<ClientResponse>
    func send(_ content: MailgunTemplateMessage) -> EventLoopFuture<ClientResponse>
    func setup(forwarding: MailgunRouteSetup) -> EventLoopFuture<ClientResponse>
    func createTemplate(_ template: MailgunTemplate) -> EventLoopFuture<ClientResponse>
    
    func `for`(_ req: Request) -> Self
}

public struct MailgunClient: MailgunProvider {
    let config: MailgunConfiguration
    let eventLoop: EventLoop
    let client: Client
    var domain: MailgunDomain
    
    // MARK: Initialization
    public init(
        config: MailgunConfiguration,
        eventLoop: EventLoop,
        client: Client,
        domain: MailgunDomain
    ) {
        self.config = config
        self.eventLoop = eventLoop
        self.client = client
        self.domain = domain
    }
    
    public func `for`(_ req: Request) -> MailgunClient {
        return MailgunClient(config: config, eventLoop: req.eventLoop, client: req.client, domain: domain)
    }
}

// MARK: - Send message

extension MailgunClient {
    /// Base API URL based on the current region
    var baseApiUrl: String {
        switch domain.region {
        case .us: return "https://api.mailgun.net/v3"
        case .eu: return "https://api.eu.mailgun.net/v3"
        }
    }
    
    /// Send message
    ///
    /// - Parameters:
    ///   - content: Message
    ///   - container: Container
    /// - Returns: Future<Response>
    public func send(_ content: MailgunMessage) -> EventLoopFuture<ClientResponse> {
        postRequest(content, endpoint: "messages")
    }

    /// Send message
    ///
    /// - Parameters:
    ///   - content: TemplateMessage
    ///   - container: Container
    /// - Returns: Future<Response>
    public func send(_ content: MailgunTemplateMessage) -> EventLoopFuture<ClientResponse> {
        postRequest(content, endpoint: "messages")
    }
    
    /// Setup forwarding
    ///
    /// - Parameters:
    ///   - setup: RouteSetup
    ///   - container: Container
    /// - Returns: Future<Response>
    public func setup(forwarding setup: MailgunRouteSetup) -> EventLoopFuture<ClientResponse> {
        postRequest(setup, endpoint: "v3/routes")
    }

    /// Create template
    ///
    /// - Parameters:
    ///   - template: Template
    ///   - container: Container
    /// - Returns: Future<Response>
    public func createTemplate(_ template: MailgunTemplate) -> EventLoopFuture<ClientResponse> {
        postRequest(template, endpoint: "templates")
    }
}

// MARK: - Conversions

extension Array where Element == MailgunMessage.FullEmail {
    var stringArray: [String] {
        map { entry in
            guard let name = entry.name else {
                return entry.email
            }
            return "\"\(name) <\(entry.email)>\""
        }
    }
}
