📊 TradeX Lite

TradeX Lite is a Flutter-based stock tracking and analysis application that allows users to view market data, manage watchlists, and customize app preferences.
It uses local storage (Hive) for data persistence and supports biometric-secured login.

🔐 Authentication

*Login with username and password.

*Biometric authentication using fingerprint or Face ID.

*Auto-login if biometrics are enabled.


📈 Market Watch

*Displays a list of mock stock data with periodic price updates.

*Lazy loading (infinite scroll) for stock data.

*Search by stock name or symbol.

⭐ Watchlist

*Add or remove stocks with a single tap.

*Reorder watchlist items with drag and drop.

*Watchlist data stored locally using Hive.

⚙️ Settings

*Toggle between light and dark themes.

*Set data refresh intervals (5s / 10s / 30s).

*Choose preferred display currency (INR or USD).

*All preferences are persisted locally.

🔒 Logout and Cache Management

* Secure logout that clears cached Hive data and resets login state.
  
* Optionally preserve theme or currency settings if needed.





Setup Instructions
1. Clone the Repository
[git clone https://github.com/your-username/tradex-lite.git](https://github.com/MufcVarun11/TradeX-Lite.git)

  cd tradex-lite

2. Install Dependencies
flutter pub get

3. Run the Application
flutter run

4. Build the Apk
   
flutter build apk









Screenshots

<img width="1408" height="2974" alt="image" src="https://github.com/user-attachments/assets/cf4b0b4e-5096-4144-8893-724e6dd05483" />


<img width="1408" height="2974" alt="image" src="https://github.com/user-attachments/assets/203598be-935c-4992-9bda-0e6caddd32b3" />

<img width="1408" height="2974" alt="image" src="https://github.com/user-attachments/assets/d98561b8-a71d-466b-900b-f7becf43dcbf" />

<img width="1408" height="2974" alt="image" src="https://github.com/user-attachments/assets/ba8f6e34-1ce0-453e-a2f1-53a1d404f92b" />




