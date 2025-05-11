# OpenRouter Credit App

A macOS menu bar application that displays your OpenRouter credit usage.

## Features

- Shows your current OpenRouter credit spending in the menu bar
- Displays amount of remaining credits in the MenuBar—that's it
- Automatically refreshes data every 30 minutes, possible with Force-Refresh too
- Securely stores your API key in UserDefaults

## Requirements

- macOS 10.15 or later
- An OpenRouter API key

## Setup

1. Build the application using the provided build script
2. Run the application
3. Click on the menu bar icon and select "Set API Key"
4. Enter your OpenRouter API key
5. The app will automatically fetch and display your credit usage

## How to Get Your OpenRouter API Key

1. Go to [OpenRouter](https://openrouter.ai/)
2. Sign in to your account
3. Navigate to your account settings
4. Find and copy your API key

## Building from Source

No Xcode required! Just use the included build script:

```bash
# Clone the repository
git clone https://github.com/yourusername/OpenRouterCreditApp.git
cd OpenRouterCreditApp

# Build the app
./build.sh

# Run the app
open OpenRouterCreditApp.app
```

## Usage

- Left-click on the menu bar icon to see detailed credit information
- Right-click on the menu bar icon for additional options:
  - Refresh: Update credit information immediately
  - Quit: Exit the application

## Development

This app is built using SwiftUI and follows the MVVM pattern:
- `OpenRouterCreditApp.swift`: Main app entry point
- `OpenRouterAPI.swift`: API service for fetching credit information
- `CreditView.swift`: UI components and view model

## Project Structure

- `Sources/`: Contains the Swift source files
- `Assets.xcassets/`: Contains app icons and other assets
- `build.sh`: Script to build the app without Xcode
- `OpenRouterCreditApp.entitlements`: App security entitlements