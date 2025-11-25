# Deploy ReporterRegistry Contract

## Option 1: Using Foundry (Recommended)

### Prerequisites
- Foundry installed (`curl -L https://foundry.paradigm.xyz | bash`)
- Private key with MATIC on Polygon Amoy

### Steps

1. **Set Environment Variable**
```bash
export PRIVATE_KEY=your_private_key_here
```

2. **Deploy Contract**
```bash
cd backend

forge script script/DeployReporterRegistry.s.sol \
  --rpc-url https://polygon-amoy.infura.io/v3/b0f04bd3f6a949e59cd25a1bc364d588 \
  --broadcast \
  --verify \
  -vvvv
```

3. **Copy Deployed Address**
The output will show:
```
ReporterRegistry deployed at: 0x...
```

4. **Update Frontend**
Edit `frontend/src/lib/contracts.ts`:
```typescript
ReporterRegistry: '0xYOUR_DEPLOYED_ADDRESS',
```

---

## Option 2: Using Remix IDE (No CLI needed)

### Steps

1. **Go to Remix**: https://remix.ethereum.org

2. **Create New File**: `ReporterRegistry.sol`
   - Copy entire content from `backend/src/verification/ReporterRegistry.sol`
   - Also need to copy `backend/src/tokens/NEWS.sol`

3. **Compile**
   - Click "Solidity Compiler" tab
   - Select compiler version: `0.8.24`
   - Click "Compile ReporterRegistry.sol"

4. **Deploy**
   - Click "Deploy & Run Transactions" tab
   - Environment: "Injected Provider - MetaMask"
   - Make sure MetaMask is on Polygon Amoy
   - Contract: Select "ReporterRegistry"
   - Constructor Arguments:
     - `_newsToken`: `0xd3091433da9a925c38682b28ffbae975ed06617a`
     - `initialOwner`: Your wallet address
   - Click "Deploy"
   - Confirm in MetaMask

5. **Copy Address**
   - After deployment, copy the contract address
   - Update `frontend/src/lib/contracts.ts`

---

## Option 3: Use Demo Contract (Quick Start)

If someone has already deployed ReporterRegistry, get the address and update:

```typescript
// frontend/src/lib/contracts.ts
ReporterRegistry: '0xDEMO_CONTRACT_ADDRESS',
```

---

## Verify Deployment

Test in frontend:
1. Go to http://localhost:3000/reporter
2. Try registering as reporter
3. Use Demo Helper to auto-verify
4. Should work without errors

---

## Troubleshooting

**"vm.envUint: environment variable not found"**
- Set PRIVATE_KEY environment variable
- Use `export PRIVATE_KEY=...` (Mac/Linux)
- Use `set PRIVATE_KEY=...` (Windows CMD)

**"Insufficient funds"**
- Get test MATIC from faucet
- Need ~0.01 MATIC for deployment

**"Contract already deployed"**
- Use the existing address
- Update contracts.ts
- Don't re-deploy

---

## After Deployment

1. ✅ Update `CONTRACT_ADDRESSES.ReporterRegistry` in `contracts.ts`
2. ✅ Commit the change
3. ✅ Restart frontend dev server
4. ✅ Test complete flow
5. ✅ Demo is ready!
