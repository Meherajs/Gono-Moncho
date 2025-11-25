# Gono Moncho - Judge Prototype Demo Guide

## 🎯 Demo Flow Overview

This demo showcases the complete Gono Moncho decentralized journalism platform with **FREE operations** for prototype demonstration.

### Demo Features (All FREE in Testing Mode)
- ✅ Reporter Registration (No staking required)
- ✅ Automatic Verification (Instant approval)
- ✅ Article Publishing to Arweave & Blockchain (Free)
- ✅ Article Reading & Voting (Free on Polygon Amoy)
- ✅ Mock Arweave Storage (Development mode)

---

## 🚀 Quick Start

### 1. Start the Development Server
```bash
cd frontend
npm run dev
```
Access at: http://localhost:3000

### 2. Connect MetaMask to Polygon Amoy

**Network Details:**
- Network Name: Polygon Amoy Testnet
- RPC URL: https://polygon-amoy.infura.io/v3/b0f04bd3f6a949e59cd25a1bc364d588
- Chain ID: 80002
- Currency Symbol: MATIC
- Block Explorer: https://amoy.polygonscan.com/

**Get Test MATIC:**
- Faucet: https://faucet.polygon.technology/

---

## 👥 Demo User Flows

### Flow 1: Reporter Journey (Main Demo)

#### Step 1: Register as Reporter
1. Navigate to **Reporter Portal** (top navigation)
2. Fill in credentials:
   - Name: Your name
   - Organization: News outlet
   - Experience: Years of journalism
   - Portfolio: Website or LinkedIn
3. Select Role: **Reporter**
4. Click **Register as Reporter**
5. ✅ **No wallet prompt** - Registration is FREE in testing mode
6. Status shows: "Pending Verification"

#### Step 2: Get Auto-Verified (Demo Feature)
- In testing mode, reporters can publish immediately after registration
- The system shows "VERIFIED" status
- Mock staking shows balance without actual token transfer

#### Step 3: Upload Content to Arweave
1. Go to **Upload Content** tab
2. Create your article content (JSON format):
   ```json
   {
     "title": "Breaking: Decentralized News Platform Launches",
     "content": "Full article content here...",
     "author": "Your Name",
     "date": "2025-11-25",
     "tags": ["blockchain", "journalism", "web3"]
   }
   ```
3. Click **Upload JSON to Arweave**
4. Copy the generated Arweave hash (e.g., `mock_arweave_abc123...`)

#### Step 4: Publish to Blockchain
1. Go to **Publish Article** tab
2. Paste the Arweave hash
3. Click **Publish to Blockchain**
4. Approve MetaMask transaction (FREE - testnet)
5. ✅ Article is now published!

#### Step 5: View Published Article
1. Navigate to **Home** or **News Feed**
2. Your article appears in the feed
3. Shows: Arweave hash, credibility score, verification status

---

### Flow 2: Regular User Journey

#### Step 1: Browse Articles
1. Go to homepage
2. View all published articles
3. Click on any article to read details

#### Step 2: Vote on Articles
1. Click **Vote** on an article
2. Choose: Support (👍) or Against (👎)
3. Enter vote weight (1-10)
4. Approve MetaMask transaction (FREE - testnet)
5. ✅ Vote recorded on blockchain

#### Step 3: View Governance
1. Navigate to **Governance** page
2. See all active proposals
3. View voting results
4. Participate in DAO decisions

---

## 🔧 Technical Details

### Smart Contracts (Polygon Amoy)

```
NEWS Token:           0xd3091433da9a925c38682b28ffbae975ed06617a
CRED Token:           0x95e29667e07767bd019b4a79f3979a416c30f573
NewsStaking:          0x58321d7cb23248ca3f39f01e4480f4a8b166bfec
NewsDAO:              0xccf0212b8c443ee148a36106f109b7b3c5250f51
Verification:         0xe5672b7bf38e11d81feb07d77a35cf5499a0adeb
ArweaveStorage:       0xc7311a7c71647edd9556938ad6f22afe4dc01a66
DelegationRegistry:   0xea67b90c7d566ae98c4906fa8962844fb424e4f0
ReporterRegistry:     [Deploy before demo]
```

### Testing Mode Features

**ReporterRegistry.sol - Testing Mode Enabled:**
- `testingMode = true` - Set in constructor
- `isFreeTestAccount = true` - Auto-set for all registrations
- No token transfers required for staking
- Reporters can publish immediately after registration

**Benefits for Demo:**
- No need for test tokens
- Instant verification
- Focus on user experience, not blockchain complexity
- All features work without wallet balance

---

## 🎨 UI Features to Showcase

### 1. Reporter Portal (3 Tabs)
- **Register**: Beautiful form with role selection
- **Upload**: Drag & drop Arweave uploader with hash display
- **Publish**: Two-step process (Arweave → Blockchain)

### 2. Home Page
- Article feed with credibility scores
- Verification status badges
- Vote buttons with real-time updates

### 3. Governance Page
- Active proposals list
- Quadratic voting interface
- DAO participation stats

### 4. Header Navigation
- Clean design with Reporter Portal link
- Wallet connection button
- Network indicator

---

## 📋 Demo Script for Judges

### Opening (30 seconds)
> "Gono Moncho is a decentralized journalism platform that combines blockchain transparency with AI-powered verification. Let me show you how reporters publish and readers verify news articles."

### Reporter Registration (1 minute)
1. Click "Reporter Portal"
2. Fill form with example credentials
3. Click "Register as Reporter"
4. Show instant verification status

### Article Publishing (2 minutes)
1. Switch to "Upload Content" tab
2. Paste example JSON article
3. Click "Upload JSON to Arweave"
4. Copy generated hash
5. Switch to "Publish Article" tab
6. Paste hash and publish
7. Show MetaMask confirmation
8. Navigate to homepage and show published article

### User Voting (1 minute)
1. Show published article in feed
2. Click "Vote" button
3. Select support/against
4. Confirm transaction
5. Show updated vote count

### Closing (30 seconds)
> "All operations are free in testing mode. The platform supports permanent storage on Arweave, credibility scoring, and democratic governance through our DAO. Questions?"

---

## 🐛 Troubleshooting

### MetaMask Shows Wrong Network
- Click MetaMask → Networks → Add Polygon Amoy
- Use RPC URL from this guide

### "Insufficient Funds" Error
- Get test MATIC from faucet
- Only need ~0.1 MATIC for multiple transactions

### Article Not Appearing
- Wait 5-10 seconds for blockchain confirmation
- Refresh the page
- Check transaction on Amoy explorer

### "Not Verified Reporter" Error
- Ensure you registered as Reporter
- Testing mode should auto-verify
- Try refreshing the page

---

## 📊 What Judges Will See

### ✅ Working Features
1. **Free Registration** - No token barriers
2. **Arweave Integration** - Mock IDs generated
3. **Blockchain Publishing** - Real transactions on Amoy
4. **Article Feed** - Dynamic content display
5. **Voting System** - Real governance participation
6. **Credibility Scores** - Calculated from verification

### 🚧 Development Mode Indicators
1. Mock Arweave IDs (43-char base64url format)
2. IPFS hashes generated locally
3. Auto-verification for testing
4. No actual token staking required

### 🔮 Production-Ready Architecture
- All contracts auditable on-chain
- Clear migration path to real Arweave/Bundlr
- Comprehensive ABIs for frontend integration
- Testing mode can be disabled post-demo

---

## 💡 Key Talking Points

1. **Decentralization**: All articles stored on Arweave (permanent), verified on blockchain
2. **Free Testing**: Testing mode removes financial barriers for prototype
3. **Role-Based Access**: Reporters, Analyzers, Verifiers each have specific permissions
4. **Transparency**: All votes, publications, and verifications are on-chain
5. **Scalability**: Built on Polygon for low gas fees
6. **AI Integration**: Oracle ready for credibility analysis (future feature)

---

## 🎯 Success Criteria

By end of demo, judges should see:
- ✅ Reporter registered and verified
- ✅ Article uploaded to "Arweave" (mock)
- ✅ Article published to blockchain (real)
- ✅ Article visible in feed
- ✅ Vote cast on article (real transaction)
- ✅ All operations completed FREE

---

## 📞 Support

For demo day issues:
1. Check MetaMask is on Polygon Amoy
2. Ensure dev server is running (localhost:3000)
3. Verify faucet provided test MATIC
4. Clear browser cache if needed

**Good luck with the demo! 🚀**
