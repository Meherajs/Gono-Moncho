# Gono-Moncho Frontend

Decentralized news verification platform built with Next.js 15, React 19, and Web3 technologies.

## Features

- 🔐 Web3 wallet integration (MetaMask, WalletConnect)
- 📰 Decentralized news publishing and verification
- 🗳️ DAO governance participation
- 💰 Token staking and rewards
- 🔍 News credibility scoring

## Tech Stack

- **Framework**: Next.js 15.4.5 (App Router)
- **Web3**: Wagmi 2.16.1, Viem 2.33.2
- **Styling**: Tailwind CSS
- **Blockchain**: Polygon Amoy Testnet

## Getting Started

### Prerequisites

- Node.js 18+
- MetaMask or compatible Web3 wallet

### Installation

```bash
npm install
```

### Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

### Build

```bash
npm run build
npm start
```

## Deployed Contracts

The frontend connects to smart contracts deployed on Polygon Amoy testnet. Contract addresses are configured in `src/lib/contracts.ts`.

## Project Structure

```
src/
├── app/              # Next.js app router pages
├── components/       # React components
├── context/          # React context providers
├── lib/              # Contract ABIs and utilities
└── Hooks/            # Custom React hooks
```

## Environment Setup

1. Get testnet POL from [Polygon Faucet](https://faucet.polygon.technology/)
2. Connect MetaMask to Polygon Amoy testnet
3. Start publishing and verifying news!

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [Wagmi Documentation](https://wagmi.sh)
- [Polygon Documentation](https://docs.polygon.technology/)
