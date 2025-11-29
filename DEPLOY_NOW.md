# Deploy ReporterRegistry - Quick Guide

## Option 1: Deploy via Remix (Easiest - No Command Line)

1. **Go to Remix IDE**: https://remix.ethereum.org

2. **Create new file**: `ReporterRegistry.sol`

3. **Copy the contract code** from `backend/src/verification/ReporterRegistry.sol`

4. **Also copy** `backend/src/tokens/NEWS.sol` (needed for compilation)

5. **Compile**:
   - Click "Solidity Compiler" tab
   - Select version: `0.8.24`
   - Click "Compile ReporterRegistry.sol"

6. **Deploy**:
   - Click "Deploy & Run Transactions" tab
   - Environment: "Injected Provider - MetaMask"
   - Make sure MetaMask is on **Polygon Amoy**
   - Contract: Select "ReporterRegistry"
   - Constructor Arguments:
     - `_newsToken`: `0xd3091433da9a925c38682b28ffbae975ed06617a`
     - `initialOwner`: YOUR_WALLET_ADDRESS (your MetaMask address)
   - Click "Deploy"
   - Confirm in MetaMask

7. **Copy the deployed address** from Remix

8. **Update frontend**:
   Edit `frontend/src/lib/contracts.ts` line 12:
   ```typescript
   ReporterRegistry: '0xYOUR_DEPLOYED_ADDRESS_HERE',
   ```

9. **Restart dev server**:
   ```bash
   cd frontend
   npm run dev
   ```

## Option 2: Deploy via Foundry (Command Line)

```bash
cd backend

# Set your private key (the one with MATIC)
export PRIVATE_KEY=your_private_key_here

# Deploy
forge script script/DeployReporterRegistry.s.sol \
  --rpc-url https://polygon-amoy.infura.io/v3/b0f04bd3f6a949e59cd25a1bc364d588 \
  --broadcast \
  -vvvv

# Copy the deployed address and update contracts.ts
```

## Then Update Frontend

Edit `frontend/src/lib/contracts.ts`:
```typescript
ReporterRegistry: '0xYOUR_DEPLOYED_ADDRESS',
```

Restart server and try again!
