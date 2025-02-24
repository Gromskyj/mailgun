import Vapor

extension MailgunClient {
    func postRequest<Message: Content>(_ content: Message, endpoint: String) async throws -> ClientResponse {
        let authKeyEncoded = try self.encode(apiKey: config.apiKey)
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Basic \(authKeyEncoded)")

        let mailgunURI = URI(string: "\(self.baseApiUrl)/\(self.domain.domain)/\(endpoint)")
        let response = try await client.post(mailgunURI, headers: headers) { req in
            try req.content.encode(content)
        }
        return try self.parse(response: response)
    }
}
