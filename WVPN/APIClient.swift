import Foundation

struct APIClient {
    var baseURL = URL(string: "http://localhost:8080")!
    var token = "local-development-only"
    var accountID = "00000000-0000-0000-0000-000000000001"

    func regions() async throws -> [Region] {
        var request = URLRequest(url: baseURL.appending(path: "/v1/regions"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(accountID, forHTTPHeaderField: "X-Account-ID")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode([Region].self, from: data)
    }
}

