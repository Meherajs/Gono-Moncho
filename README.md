# Gono Moncho: Decentralized News Ecosystem

Gono Moncho is a decentralized, Sybil-resistant ecosystem for verifiable journalism that leverages blockchain technology to combat censorship, misinformation, and centralized control of news media.

## Overview

Gono Moncho addresses critical challenges in modern journalism:

- 🚫 Government censorship and oppression of journalists
- 🤥 Spread of misinformation and fake news
- 🕵️‍♂️ Lack of journalist anonymity and security
- 🏛️ Centralized control of media narratives

The platform implements:

- 🔐 Privacy-preserving publishing with Zero-Knowledge Proofs
- ⚖️ Dual-token economic model (NEWS + CRED)
- 🗳️ Decentralized autonomous organization (NewsDAO)
- ✅ Multi-layered verification protocol
- 🌐 Permanent, immutable storage via Arweave

## Repository Structure

```
gono-moncho/
├── backend/          # Solidity smart contracts (Foundry)
│   ├── src/         # Smart contract source code
│   ├── test/        # Contract tests
│   └── script/      # Deployment scripts
└── frontend/         # Next.js Web3 DApp
    ├── src/         # Frontend source code
    └── public/      # Static assets
```

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Node.js 18+ installed
- MetaMask browser extension
- Git

### 1. Clone & Install
```bash
git clone https://github.com/ByzentineGenerals/Gono-Moncho.git
cd Gono-Moncho/frontend
npm install
```

### 2. Start Development Server
```bash
npm run dev
```
Access at: http://localhost:3000

### 3. Configure MetaMask

**Add Polygon Amoy Testnet:**
- Network Name: `Polygon Amoy Testnet`
- RPC URL: `https://polygon-amoy.infura.io/v3/b0f04bd3f6a949e59cd25a1bc364d588`
- Chain ID: `80002`
- Currency Symbol: `MATIC`
- Block Explorer: `https://amoy.polygonscan.com/`

**Get Test MATIC:**
Visit https://faucet.polygon.technology/

---

## 🎯 Demo / Judge Presentation

### Complete Demo Flow (5 minutes)

**All operations are FREE in testing mode!**

#### 1. Reporter Registration (1 min)
1. Navigate to **Reporter Portal** (top navigation)
2. Fill in credentials form
3. Select Role: **Reporter**
4. Click **Register as Reporter** → FREE (no MetaMask prompt)

#### 2. Auto-Verification (30 sec)
1. Click **Demo Helper** button (bottom-right floating button)
2. Click **"Auto-Verify Me as Reporter"**
3. Approve MetaMask transaction (FREE on testnet)
4. Wait for confirmation → Status shows "VERIFIED" ✅

#### 3. Upload Article to Arweave (1 min)
1. Go to **Upload Content** tab
2. Paste article JSON:
```json
{
  "title": "Blockchain Revolutionizes Journalism",
  "content": "Decentralized platforms are changing how news is verified...",
  "author": "Your Name",
  "date": "2025-11-25"
}
```
3. Click **Upload JSON to Arweave**
4. Copy generated Arweave hash

#### 4. Publish to Blockchain (1 min)
1. Go to **Publish Article** tab
2. Paste Arweave hash
3. Click **Publish to Blockchain**
4. Approve MetaMask (FREE testnet transaction)
5. Article published! 🎉

#### 5. Vote on Articles (30 sec)
1. Navigate to **Home** page
2. Click **Vote** on any article
3. Choose Support (👍) or Against (👎)
4. Enter vote weight (1-10)
5. Approve MetaMask (FREE testnet)
6. Vote recorded on-chain!

### 🎤 Presentation Script

**Opening (30 sec):**
> "Gono Moncho solves fake news through blockchain transparency and permanent storage. Reporters verify credentials, articles are stored permanently on Arweave, and community governance determines credibility through on-chain voting."

**Live Demo (3.5 min):**
Follow the 5-step flow above

**Technical Highlights (1 min):**
- ✅ Role-Based Access Control (Reporter/Analyzer/Verifier)
- ✅ Permanent Storage on Arweave
- ✅ Scalable on Polygon L2
- ✅ DAO Governance with Quadratic Voting
- ✅ Testing Mode for Easy Demos

**Closing (30 sec):**
> "Production-ready architecture with clear migration from testing to mainnet. All smart contracts deployed, frontend responsive, end-to-end features working."

---

## 📋 Deployed Contracts (Polygon Amoy Testnet)

| Contract | Address |
|----------|----------|
| NEWS Token | `0xd3091433da9a925c38682b28ffbae975ed06617a` |
| CRED Token | `0x95e29667e07767bd019b4a79f3979a416c30f573` |
| NewsStaking | `0x58321d7cb23248ca3f39f01e4480f4a8b166bfec` |
| NewsDAO | `0xccf0212b8c443ee148a36106f109b7b3c5250f51` |
| Verification | `0xe5672b7bf38e11d81feb07d77a35cf5499a0adeb` |
| ArweaveStorage | `0xc7311a7c71647edd9556938ad6f22afe4dc01a66` |
| DelegationRegistry | `0xea67b90c7d566ae98c4906fa8962844fb424e4f0` |
| ReporterRegistry | *Deploy before demo (see below)* |

---

## 🔧 Deploy ReporterRegistry (Optional)

### Option 1: Using Foundry
```bash
cd backend
export PRIVATE_KEY=your_private_key_here

forge script script/DeployReporterRegistry.s.sol \
  --rpc-url https://polygon-amoy.infura.io/v3/b0f04bd3f6a949e59cd25a1bc364d588 \
  --broadcast -vvvv
```

### Option 2: Using Remix IDE
1. Go to https://remix.ethereum.org
2. Copy `backend/src/verification/ReporterRegistry.sol`
3. Compile with Solidity 0.8.24
4. Deploy with:
   - `_newsToken`: `0xd3091433da9a925c38682b28ffbae975ed06617a`
   - `initialOwner`: Your wallet address
5. Copy deployed address

### Update Frontend
Edit `frontend/src/lib/contracts.ts`:
```typescript
ReporterRegistry: '0xYOUR_DEPLOYED_ADDRESS',
```

---

## 💻 Development

### Backend (Smart Contracts)

```bash
cd backend

# Install dependencies
forge install

# Compile contracts
forge build

# Run tests (27 tests)
forge test

# Run specific test
forge test --match-test testRegisterReporter

# Deploy all contracts
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast
```

### Frontend (DApp)

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

### Testing Mode Features

**ReporterRegistry Contract:**
- `testingMode = true` - Enabled by default
- Free registration (no staking required)
- Auto-marks accounts as `isFreeTestAccount`
- Reporters can publish immediately after verification

**Benefits:**
- No need for test tokens
- Focus on UX demonstration
- Easy judge presentations
- Production mode available (disable testingMode)

---

## 🏗️ Architecture

### Smart Contracts

**Token Layer:**
- `NEWS.sol` - Governance & staking token
- `CRED.sol` - Reputation token (non-transferable)

**Governance Layer:**
- `NewsDAO.sol` - DAO governance with quadratic voting
- `DelegationRegistry.sol` - Liquid democracy

**Verification Layer:**
- `Verification.sol` - Multi-layered article verification
- `ReporterRegistry.sol` - Role-based access control
- `SANUB.sol` - Sybil resistance protocol

**Storage Layer:**
- `ArweaveStorage.sol` - Permanent storage integration
- `AIOracle.sol` - AI credibility analysis

**Staking Layer:**
- `NewsStaking.sol` - Token staking & rewards

### Frontend Components

**Pages:**
- `/` - Home page with article feed
- `/reporter` - Reporter portal (Register, Upload, Publish)
- `/governance` - DAO proposals and voting
- `/publish` - Article publishing (redirects to /reporter)

**Key Components:**
- `ReporterRegistration.tsx` - Reporter onboarding
- `ArweaveUploadHelper.tsx` - File/JSON upload to Arweave
- `PublishForm.tsx` - Two-step publishing (Arweave → Blockchain)
- `DemoHelper.tsx` - Auto-verification for demos
- `Header.tsx` - Navigation with wallet connection

**API Routes:**
- `/api/arweave/upload` - Mock Arweave upload (development)

---

## 🔐 Production Arweave Integration

For production deployment with real Arweave storage:

### 1. Install Bundlr SDK
```bash
cd frontend
npm install @bundlr-network/client
```

### 2. Set Environment Variables
Create `frontend/.env.local`:
```bash
BUNDLR_NODE_URL=https://node2.bundlr.network
BUNDLR_PRIVATE_KEY=your_wallet_private_key
BUNDLR_CURRENCY=matic  # For Polygon
```

### 3. Update API Route
Replace mock implementation in `frontend/src/app/api/arweave/upload/route.ts` with:
```typescript
import Bundlr from '@bundlr-network/client';

const bundlr = new Bundlr(
  process.env.BUNDLR_NODE_URL!,
  process.env.BUNDLR_CURRENCY!,
  process.env.BUNDLR_PRIVATE_KEY!
);

// Upload to real Arweave
const tx = await bundlr.upload(fileBuffer, {
  tags: [
    { name: "Content-Type", value: "application/json" },
    { name: "App-Name", value: "Gono-Moncho" }
  ]
});
```

### 4. Fund Bundlr Account
```bash
# Check balance
bundlr balance

# Fund account (0.1 MATIC example)
bundlr fund 100000000000000000
```

---

## 🧪 Testing

### Smart Contract Tests
```bash
cd backend
forge test -vvv
```

**Test Coverage:**
- ✅ Token minting & transfers (NEWS, CRED)
- ✅ Staking & unstaking
- ✅ Reporter registration & verification
- ✅ Article publishing & verification
- ✅ DAO governance & voting
- ✅ Quadratic voting calculations
- ✅ Role-based permissions

### Frontend Testing
Manual testing checklist:
- [ ] MetaMask connection
- [ ] Network switching to Polygon Amoy
- [ ] Reporter registration
- [ ] Auto-verification via Demo Helper
- [ ] Arweave upload
- [ ] Article publishing
- [ ] Voting on articles
- [ ] Proposal creation

---

## 🐛 Troubleshooting

### "MetaMask shows Ethereum Mainnet"
- Manually add Polygon Amoy network (see Quick Start)
- Switch network in MetaMask

### "Insufficient funds" error
- Get test MATIC from faucet: https://faucet.polygon.technology/
- Need ~0.1 MATIC for multiple transactions

### "Article not appearing in feed"
- Wait 10-15 seconds for blockchain confirmation
- Refresh the page
- Check transaction on explorer

### "Not verified reporter" error
- Use Demo Helper button (bottom-right)
- Click "Auto-Verify Me as Reporter"
- Wait for transaction confirmation

### "Demo Helper button not showing"
- Deploy ReporterRegistry contract
- Update address in `frontend/src/lib/contracts.ts`
- Restart dev server

---

## 🛠️ Technology Stack

### Blockchain
- **Network:** Polygon Amoy Testnet (Chain ID: 80002)
- **Smart Contracts:** Solidity 0.8.24
- **Framework:** Foundry (forge, anvil, cast)
- **Testing:** Foundry Test Suite

### Frontend
- **Framework:** Next.js 15.4.5 + React 19.1.0
- **Web3:** Wagmi 2.16.1 + Viem 2.33.2
- **Build Tool:** Turbopack
- **Styling:** Tailwind CSS
- **Package Manager:** npm

### Storage
- **Development:** Mock Arweave IDs (43-char base64url)
- **Production:** Bundlr/Irys for Arweave uploads
- **Metadata:** IPFS (via mock in development)

### Infrastructure
- **RPC:** Infura (Polygon Amoy)
- **Block Explorer:** Amoy PolygonScan
- **Faucet:** Polygon Faucet

---

## 📊 Features

### ✅ Working Features
- Reporter registration (role-based: Reporter/Analyzer/Verifier)
- Auto-verification for demos (Demo Helper)
- Arweave integration (mock in dev, production-ready)
- Article publishing to blockchain
- Article feed with credibility scores
- Voting system (on-chain governance)
- DAO proposals
- Quadratic voting
- Delegation system
- Staking & rewards

### 🚧 Development Features
- Mock Arweave uploads
- Testing mode (free operations)
- Auto-verification helper
- Local IPFS metadata generation

### 🔮 Roadmap
- AI-powered credibility analysis
- Zero-knowledge proofs for privacy
- Cross-chain deployment
- Mobile app
- Real-time notifications
- Enhanced analytics dashboard

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📄 License

MIT License - see LICENSE file for details

---

## 📞 Support

- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions
- **Documentation:** This README

---

## 🎯 Project Status

- **Stage:** Beta / Demo Ready
- **Smart Contracts:** Deployed on Polygon Amoy
- **Frontend:** Fully functional
- **Testing Mode:** Active
- **Production Ready:** Architecture complete, migration path documented

**Last Updated:** November 25, 2025
