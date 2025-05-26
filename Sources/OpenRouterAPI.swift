import Foundation

struct CreditInfo: Codable {
    let spent: Double
    let remaining: Double
    let limit: Double
    let lastUpdated: Date

    init(spent: Double, remaining: Double, limit: Double) {
        self.spent = spent
        self.remaining = remaining
        self.limit = limit
        self.lastUpdated = Date()
    }
}

class OpenRouterAPI {
    var creditInfo: CreditInfo?

    private var apiKey: String? {
        return UserDefaults.standard.string(forKey: "openRouterAPIKey")
    }

    init() {
        // API key is now loaded dynamically from UserDefaults
    }

    func saveAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "openRouterAPIKey")
    }

    func fetchCreditUsage(completion: @escaping () -> Void) {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            print("No API key available")
            completion()
            return
        }

        guard let url = URL(string: "https://openrouter.ai/api/v1/credits") else {
            print("Invalid URL")
            completion()
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching credit info: \(error)")
                completion()
                return
            }

            guard let data = data else {
                print("No data received")
                completion()
                return
            }

            do {
                // Parse the JSON response from the credits endpoint
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responseData = json["data"] as? [String: Any] {

                    let totalUsage = (responseData["total_usage"] as? Double) ?? 0.0
                    let totalCredits = (responseData["total_credits"] as? Double) ?? 0.0

                    // Calculate remaining as total_credits minus total_usage
                    let remaining = totalCredits - totalUsage

                    // Total limit is the total credits
                    let limit = totalCredits

                    self?.creditInfo = CreditInfo(spent: totalUsage, remaining: remaining, limit: limit)
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }

            completion()
        }

        task.resume()
    }
}