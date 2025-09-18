# 💰 Expense Manager DApp

<div align="center">


<img width="416" height="868" alt="Screenshot 2025-09-19 031456" src="https://github.com/user-attachments/assets/c2ca18d1-a7f9-4132-859e-0d9d89c15643" />


*Modern Web3 Expense Tracker with Beautiful UI*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Solidity](https://img.shields.io/badge/Solidity-363636?style=for-the-badge&logo=solidity&logoColor=white)](https://soliditylang.org/)
[![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white)](https://ethereum.org/)
[![Truffle](https://img.shields.io/badge/Truffle-5E464D?style=for-the-badge&logo=truffle&logoColor=white)](https://trufflesuite.com/)

</div>


## 📱 Overview

A decentralized expense tracking application built with Flutter and Ethereum smart contracts. This DApp allows users to manage their expenses on the blockchain, providing transparency, security, and immutability to financial tracking.

### 📱 Video




https://github.com/user-attachments/assets/407b2e8f-1ea0-4933-95d9-fca4c6ab3770


## ✨ Features

### 🎨 Modern UI Design
- **Clean Material Design** interface with beautiful gradients
- **Color-coded Transactions** - Green for deposits (+), Red for withdrawals (-)
- **Real-time Balance Display** with ETH symbol
- **Responsive Design** that works on all screen sizes
- **Smooth Animations** and transitions

### 🔗 Blockchain Integration
- **Smart Contract** written in Solidity ^0.8.19
- **Real-time Balance Tracking** on Ethereum
- **Transaction History** stored permanently on blockchain
- **Web3 Integration** via web3dart package
- **Ganache Support** for local development

### 💸 Financial Features
- **Deposit ETH** with custom reasons
- **Withdraw ETH** with balance validation
- **Transaction Categories** (Deposit/Withdrawal)
- **Real-time Balance Updates**
- **Complete Transaction History**

## 🏗️ Architecture

### Frontend (Flutter)
```
lib/
├── features/
│   ├── dashboard/
│   │   ├── bloc/          # State management with BLoC
│   │   └── ui/            # Dashboard UI components
│   ├── deposit/           # Deposit functionality
│   └── withdraw/          # Withdrawal functionality
├── models/                # Data models
└── utils/                 # Utilities and colors
```

### Smart Contract (Solidity)
```
contracts/
├── ExpenseManagerContract.sol    # Main contract
└── Migrations.sol               # Truffle migrations
```

## 📋 Prerequisites

Before running this application, make sure you have:

- **Flutter SDK** (^3.5.4)
- **Node.js** and **npm**
- **Truffle Suite**
- **Ganache** (for local blockchain)
- **Android Studio** / **VS Code**

## 🚀 Installation & Setup

### 1️⃣ Clone Repository
```bash
git clone <repository-url>
cd expensetreckerdapp
```

### 2️⃣ Install Flutter Dependencies
```bash
flutter pub get
```

### 3️⃣ Install Node.js Dependencies
```bash
npm install
```

### 4️⃣ Start Ganache
```bash
# Option 1: Using Ganache CLI
npx ganache -p 7545 -i 5777 -h 0.0.0.0 --deterministic

# Option 2: Using Ganache GUI
# Download and install Ganache GUI from https://trufflesuite.com/ganache/
# Configure: Port 7545, Network ID 5777
```

### 5️⃣ Compile & Deploy Smart Contract
```bash
# Compile contracts
npm run compile

# Deploy to local network
npm run migrate
```

### 6️⃣ Update Contract Address
After deployment, update the contract address in:
```dart
// lib/features/dashboard/bloc/dashboard_bloc.dart
_contractAddress = EthereumAddress.fromHex("YOUR_DEPLOYED_CONTRACT_ADDRESS");
```

### 7️⃣ Run Flutter App
```bash
# For Android Emulator
flutter run

# For physical device
flutter run --release
```

## 🔧 Configuration

### Network Configuration
The app is configured to work with:
- **Local Development**: `http://127.0.0.1:7545` (Desktop)
- **Android Emulator**: `http://10.0.2.2:7545`
- **Network ID**: 5777
- **Chain ID**: 1337

### Smart Contract Features
- ✅ Deposit ETH with custom reasons
- ✅ Withdraw ETH with balance validation
- ✅ Transaction type differentiation (Deposit/Withdrawal)
- ✅ Event emission for all transactions
- ✅ Owner management functionality

## 📦 Dependencies

### Flutter Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  bloc: ^8.1.2
  flutter_bloc: ^8.1.3
  
  # Web3 Integration
  web3dart: ^2.7.3
  http: ^1.1.0
  web_socket_channel: ^2.4.4
  
  # UI Components
  flutter_svg: ^2.1.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

### Node.js Dependencies
```json
{
  "dependencies": {
    "react": "^19.1.1"
  },
  "devDependencies": {
    "truffle": "^5.11.5",
    "@truffle/hdwallet-provider": "^2.1.15"
  }
}
```

## 🎯 Usage

### Making a Deposit
1. Tap the **"+ CREDIT"** button
2. Enter the amount in ETH
3. Add a reason for the deposit
4. Confirm the transaction

### Making a Withdrawal
1. Tap the **"- DEBIT"** button
2. Enter the amount to withdraw
3. Add a reason for the withdrawal
4. Confirm the transaction (requires sufficient balance)

### Viewing Transactions
- All transactions are displayed on the main dashboard
- **Green cards** with **+** icon for deposits
- **Red cards** with **-** icon for withdrawals
- Each card shows: Amount, Address, Reason, and Timestamp

## 🔍 Smart Contract Details

### Contract Address
```
Network: Ganache Local (5777)
Address: [Generated on deployment]
Solidity Version: ^0.8.19
```

### Main Functions
```solidity
function deposit(uint _amount, string memory _reason) public payable
function withdraw(uint _amount, string memory _reason) public
function getBalance(address _account) public view returns (uint)
function getAllTransactions() public view returns (...)
```

### Events
```solidity
event Deposit(address indexed _from, uint _amount, string _reason, uint _timestamp)
event Withdrawal(address indexed _to, uint _amount, string _reason, uint _timestamp)
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Connection Refused Error
```bash
ClientException with SocketException: Connection refused
```
**Solution**: Ensure Ganache is running on the correct port (7545)

#### 2. Contract Address Mismatch
**Solution**: Update the contract address in `dashboard_bloc.dart` after deployment

#### 3. Insufficient Balance Error
**Solution**: Make a deposit before attempting withdrawals

#### 4. Android Emulator Connection
**Solution**: Use `10.0.2.2:7545` instead of `127.0.0.1:7545` for emulator

#### 5. Balance Not Updating
**Possible Causes**:
- Contract address mismatch
- Account address mismatch
- Transaction not mined yet
- Network connectivity issues

**Solution**: Check the console logs for debugging information

## 🧪 Testing

### Run Flutter Tests
```bash
flutter test
```

### Run Smart Contract Tests
```bash
npm run test
```

## 🚢 Deployment

### Local Development
1. Start Ganache
2. Deploy contracts with `npm run migrate`
3. Run Flutter app with `flutter run`

### Production Deployment
1. Update `truffle-config.js` with mainnet/testnet configuration
2. Deploy contracts to desired network
3. Update Flutter app with production contract address
4. Build and release Flutter app

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

### Special Thanks 🌟
- **Akshit Madan** - For being an incredible mentor and guide throughout this learning journey. Your expertise in blockchain development, Flutter, and Web3 technologies has been invaluable in making this project possible. Thank you for sharing your knowledge, patience, and passion for decentralized applications!

### Technology & Community
- **Flutter Team** for the amazing cross-platform framework
- **Ethereum Community** for blockchain infrastructure
- **Truffle Suite** for development tools
- **Web3Dart** package maintainers
- **Ganache developers** for the local blockchain environment

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Search existing [Issues](../../issues)
3. Create a new issue with detailed information

---

<div align="center">
  <p>Made with ❤️ and Flutter</p>
  <p>Powered by Ethereum Blockchain</p>
</div>
