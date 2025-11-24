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
└── frontend/         # Next.js Web3 DApp
```

## Deployed Contracts (Polygon Amoy Testnet)

| Contract | Address |
|----------|----------|
| NEWS Token | `0xd3091433da9a925c38682b28ffbae975ed06617a` |
| CRED Token | `0x95e29667e07767bd019b4a79f3979a416c30f573` |
| NewsStaking | `0x58321d7cb23248ca3f39f01e4480f4a8b166bfec` |
| NewsDAO | `0xccf0212b8c443ee148a36106f109b7b3c5250f51` |
| Verification | `0xe5672b7bf38e11d81feb07d77a35cf5499a0adeb` |
| ArweaveStorage | `0xc7311a7c71647edd9556938ad6f22afe4dc01a66` |
| DelegationRegistry | `0xea67b90c7d566ae98c4906fa8962844fb424e4f0` |

## Quick Start

### Backend (Smart Contracts)

```bash
cd backend
forge install
forge build
forge test
```

### Frontend (DApp)

```bash
cd frontend
npm install
npm run dev
```

## Development

See individual README files in `backend/` and `frontend/` directories for detailed setup instructions.

## Technology Stack

- **Smart Contracts**: Solidity 0.8.24, Foundry
- **Frontend**: Next.js 15, React 19, Wagmi, Viem
- **Blockchain**: Polygon Amoy Testnet
- **Storage**: Arweave (decentralized permanent storage)

## License

MIT
