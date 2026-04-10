# Flutter AI Chatbot 🤖

A clean, modern, and responsive AI Chatbot built with Flutter. This project demonstrates how to integrate external LLM APIs into a mobile application with a focus on clean architecture and smooth user experience.

## ✨ Features
- **Dual Engine**: Toggle seamlessly between **OpenAI** (GPT-4o-mini) and **Mistral AI**.
- **State Management**: Powered by `Provider` for efficient and reactive UI updates.
- **Secure Configuration**: Uses `flutter_dotenv` to keep API keys safe and out of version control.
- **Modern UI**: 
  - Adaptive chat bubbles (auto-wrapping for long messages).
  - Real-time typing indicators.
  - Dark Mode support.
  - Lottie animations for an engaging empty state.
- **Authentication**: Simple persistent login state using `shared_preferences`.

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/shkMahdi/Chat-Bot-Flutter.git
    ```
2.  **Setup Environment Variables**:
    Create a `.env` file in the root directory and add your keys:
    ```env
    OPENAI_API_KEY=your_openai_key_here
    MISTRAL_API_KEY=your_mistral_key_here
    ```
3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the App**:
    ```bash
    flutter run
    ```

## 🛠 Tech Stack
- **Framework**: Flutter
- **Language**: Dart
- **API**: OpenAI API, Mistral AI API
- **Packages**: `provider`, `http`, `flutter_dotenv`, `lottie`, `shared_preferences`, `intl`
