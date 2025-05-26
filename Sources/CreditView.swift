import SwiftUI

struct CreditView: View {
    @ObservedObject var viewModel: CreditViewModel
    @State private var apiKey: String = ""
    @State private var showingAPIKeyInput: Bool = false

    init(openRouterAPI: OpenRouterAPI) {
        self.viewModel = CreditViewModel(openRouterAPI: openRouterAPI)
        self._apiKey = State(initialValue: UserDefaults.standard.string(forKey: "openRouterAPIKey") ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.hasAPIKey && viewModel.creditInfo != nil {
                let creditInfo = viewModel.creditInfo!
                VStack(alignment: .leading, spacing: 8) {
                    Text("OpenRouter Credits")
                        .font(.headline)

                    Divider()

                    HStack {
                        Text("Remaining:")
                        Spacer()
                        Text("$\(String(format: "%.2f", creditInfo.remaining))")
                            .bold()
                    }

                    HStack {
                        Text("Spent:")
                        Spacer()
                        Text("$\(String(format: "%.2f", creditInfo.spent))")
                    }

                    HStack {
                        Text("Total Limit:")
                        Spacer()
                        Text("$\(String(format: "%.2f", creditInfo.limit))")
                    }

                    Divider()

                    Text("Last updated: \(formattedDate(creditInfo.lastUpdated))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if !viewModel.hasAPIKey {
                VStack(spacing: 12) {
                    Text("⚠️ API Key Required")
                        .font(.headline)
                        .foregroundColor(.orange)

                    Text("Please set your OpenRouter API key to view credit information.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)

                    Button("Set API Key") {
                        showingAPIKeyInput = true
                    }
                    .buttonStyle(DefaultButtonStyle())
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 8) {
                    Text("❌ Unable to load credit information")
                        .font(.headline)
                        .foregroundColor(.red)

                    Text("Please check your API key and internet connection.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            Divider()

            if showingAPIKeyInput {
                VStack(alignment: .leading) {
                    Text("Enter your OpenRouter API Key:")
                        .font(.caption)

                    SecureField("API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    HStack {
                        Button("Cancel") {
                            showingAPIKeyInput = false
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Spacer()

                        Button("Save") {
                            viewModel.saveAPIKey(apiKey)
                            showingAPIKeyInput = false
                            viewModel.refreshData()
                        }
                        .buttonStyle(DefaultButtonStyle())
                    }
                }
            } else {
                HStack {
                    Button("Refresh") {
                        viewModel.refreshData()
                    }

                    Spacer()

                    Button("Set API Key") {
                        showingAPIKeyInput = true
                    }
                }
            }
        }
        .padding()
        .frame(width: 300)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class CreditViewModel: ObservableObject {
    @Published var creditInfo: CreditInfo?
    @Published var isLoading: Bool = false
    private let openRouterAPI: OpenRouterAPI

    var hasAPIKey: Bool {
        let key = UserDefaults.standard.string(forKey: "openRouterAPIKey")
        return key != nil && !key!.isEmpty
    }

    init(openRouterAPI: OpenRouterAPI) {
        self.openRouterAPI = openRouterAPI
        refreshData()
    }

    func refreshData() {
        isLoading = true
        openRouterAPI.fetchCreditUsage { [weak self] in
            DispatchQueue.main.async {
                self?.creditInfo = self?.openRouterAPI.creditInfo
                self?.isLoading = false
            }
        }
    }

    func saveAPIKey(_ key: String) {
        openRouterAPI.saveAPIKey(key)
        // Trigger UI update by calling objectWillChange
        objectWillChange.send()
    }
}