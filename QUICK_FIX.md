# 🚀 QUICK FIX - Deploy ReporterRegistry Now!

## The Problem
You're seeing "Sending to burn address" because ReporterRegistry contract address is `0x0000...0000` (not deployed yet).

## The Solution (3 Options)

### Option 1: Deploy via Remix IDE (EASIEST - 5 minutes)

1. **Open Remix**: https://remix.ethereum.org

2. **Upload Contract Files**:
   - Create new file: `NEWS.sol`
   - Copy content from: `backend/src/tokens/NEWS.sol`
   - Create new file: `ReporterRegistry.sol`
   - Copy content from: `backend/src/verification/ReporterRegistry.sol`

3. **Compile**:
   - Click "Solidity Compiler" (left sidebar)
   - Compiler: `0.8.24`
   - Click "Compile ReporterRegistry.sol"

4. **Deploy**:
   - Click "Deploy & Run" (left sidebar)
   - Environment: **Injected Provider - MetaMask**
   - Confirm MetaMask is on **Polygon Amoy** network
   - Contract: Select `ReporterRegistry`
   - Fill constructor:
     - `_newsToken`: `0xd3091433da9a925c38682b28ffbae975ed06617a`
     - `initialOwner`: `YOUR_WALLET_ADDRESS` (from MetaMask)
   - Click **Deploy**
   - Approve in MetaMask

5. **Copy Address**:
   - After deployment, click the contract in "Deployed Contracts"
   - Copy the address (looks like `0xabc123...`)

6. **Update Frontend**:
   ```typescript
   // Edit: frontend/src/lib/contracts.ts (line 12)
   ReporterRegistry: '0xYOUR_DEPLOYED_ADDRESS_HERE',
   ```

7. **Restart Server**:
   ```bash
   cd frontend
   npm run dev
   ```

8. **Test**: Try registering as reporter again!

---

### Option 2: Use My Private Key (If You Have One)

```bash
cd backend

# Set private key
export PRIVATE_KEY=your_private_key_here

# Deploy
forge script script/DeployReporterRegistry.s.sol \
  --rpc-url https://polygon-amoy.infura.io/v3/b0f04bd3f6a949e59cd25a1bc364d588 \
  --broadcast -vvvv

# Copy the deployed address from output
# Update frontend/src/lib/contracts.ts
```

---

### Option 3: I'll Do It For You

If you send me:
1. Your wallet address (public)
2. OR give me permission to use a test private key

I can deploy and give you the address.

---

## After Deployment

### Test Registration:
1. Go to http://localhost:3000/reporter
2. Click "Register as Reporter"
3. Should work without burn address warning!

### Publish Demo Articles:
1. Go to http://localhost:3000/seed-demo
2. Click "Publish All Articles"
3. Approve transactions
4. Articles appear in feed!

---

## Quick Command Reference

```bash
# Start dev server
cd frontend && npm run dev

# Deploy contract (if using Foundry)
cd backend && forge script script/DeployReporterRegistry.s.sol --rpc-url <RPC> --broadcast

# Update contract address
# Edit: frontend/src/lib/contracts.ts line 12
```

---

**Choose Option 1 (Remix) - it's the easiest and requires no command line!**
