# Quick Demo Setup - Gono Moncho

## ⚡ 5-Minute Demo Setup

### Prerequisites
- MetaMask installed
- Node.js installed
- Git installed

### Step 1: Start Frontend (2 minutes)
```bash
cd frontend
npm install
npm run dev
```
Access at: http://localhost:3000

### Step 2: Configure MetaMask (1 minute)

**Add Polygon Amoy Testnet:**
- Network Name: `Polygon Amoy Testnet`
- RPC URL: `https://polygon-amoy.infura.io/v3/b0f04bd3f6a949e59cd25a1bc364d588`
- Chain ID: `80002`
- Currency: `MATIC`

**Get Test MATIC:**
Visit: https://faucet.polygon.technology/

### Step 3: Deploy ReporterRegistry (Optional - 2 minutes)

If you want to deploy your own contract:

```bash
cd backend

# Set your private key
export PRIVATE_KEY=your_private_key_here

# Deploy
forge script script/DeployReporterRegistry.s.sol --rpc-url https://polygon-amoy.infura.io/v3/b0f04bd3f6a949e59cd25a1bc364d588 --broadcast

# Copy the deployed address
```

Then update `frontend/src/lib/contracts.ts`:
```typescript
ReporterRegistry: '0xYOUR_DEPLOYED_ADDRESS_HERE',
```

**OR** use the existing demo contract (if already deployed).

---

## 🎯 Demo Flow (5 minutes)

### Act 1: Reporter Registration (1 min)
1. Click "Reporter Portal" in header
2. Fill form:
   - Name: "John Doe"
   - Organization: "Independent News"
   - Experience: "5 years"
   - Portfolio: "johndoe.com"
3. Click "Register as Reporter" → **FREE** (no MetaMask prompt)
4. Click **Demo Helper** button (bottom right)
5. Click "Auto-Verify Me as Reporter" → Approve MetaMask
6. Wait for confirmation → Status shows "VERIFIED"

### Act 2: Publish Article (2 min)
1. Go to "Upload Content" tab
2. Paste JSON:
```json
{
  "title": "Blockchain Revolutionizes Journalism",
  "content": "Decentralized platforms are changing how news is verified and distributed...",
  "author": "John Doe",
  "date": "2025-11-25"
}
```
3. Click "Upload JSON to Arweave" → Copy hash
4. Go to "Publish Article" tab
5. Paste hash → Click "Publish to Blockchain"
6. Approve MetaMask → Wait for confirmation

### Act 3: Read & Vote (2 min)
1. Navigate to "Home"
2. See your published article
3. Click article to read full content
4. Click "Vote" → Choose Support
5. Enter vote weight: 5
6. Approve MetaMask → Vote recorded!

---

## 🎤 Judge Presentation Script

**Opening (30 sec):**
> "Gono Moncho solves fake news through blockchain transparency and community verification. Let me show you our complete workflow in 4 minutes."

**Demo (3.5 min):**
1. **Register** - "Reporters verify credentials and stake reputation"
2. **Upload** - "Articles stored permanently on Arweave"
3. **Publish** - "On-chain publication creates immutable record"
4. **Vote** - "Community governance determines credibility"

**Tech Highlights (30 sec):**
- ✅ Polygon Amoy for scalability
- ✅ Arweave for permanent storage
- ✅ Role-based access control
- ✅ Quadratic voting for fairness
- ✅ Testing mode for easy demos

**Closing (30 sec):**
> "All operations free in testing mode. Production-ready architecture with clear migration path. Questions?"

---

## 🐛 Quick Troubleshooting

**"Transaction Fails"**
- Get more MATIC from faucet
- Check you're on Polygon Amoy

**"Not Verified Reporter"**
- Use Demo Helper button to auto-verify
- Wait 10 seconds after clicking

**"Article Not Showing"**
- Wait 15 seconds for blockchain
- Refresh page

**"Demo Helper Not Showing"**
- Deploy ReporterRegistry contract first
- Update address in contracts.ts

---

## 📊 What Judges See

✅ **Working:**
- Free registration (testing mode)
- Auto-verification (demo feature)
- Mock Arweave uploads
- Real blockchain transactions
- Article publishing & voting
- Complete UI/UX flow

🔮 **Production Ready:**
- Contract architecture
- Role-based permissions
- Arweave integration path
- DAO governance structure

---

## ⚙️ Environment Variables (Optional)

Create `frontend/.env.local`:
```
# Optional: Your own Arweave/IPFS keys
NEXT_PUBLIC_BUNDLR_KEY=your_key
NEXT_PUBLIC_IPFS_KEY=your_key
```

---

## 🚀 Demo Day Checklist

- [ ] Frontend running on localhost:3000
- [ ] MetaMask connected to Polygon Amoy
- [ ] Test MATIC in wallet (~0.1 MATIC)
- [ ] ReporterRegistry deployed (or using demo contract)
- [ ] Browser window maximized
- [ ] Demo Helper button visible
- [ ] Practice run completed

**Good luck! 🎯**
