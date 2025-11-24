# Gono-Moncho Smart Contracts

## Overview

Smart contracts for the Gono-Moncho decentralized news verification platform built with Foundry.

## Deployed Contracts (Polygon Amoy Testnet)

- **NEWS Token**: `0xd3091433da9a925c38682b28ffbae975ed06617a`
- **CRED Token**: `0x95e29667e07767bd019b4a79f3979a416c30f573`
- **NewsStaking**: `0x58321d7cb23248ca3f39f01e4480f4a8b166bfec`
- **NewsDAO**: `0xccf0212b8c443ee148a36106f109b7b3c5250f51`
- **Verification**: `0xe5672b7bf38e11d81feb07d77a35cf5499a0adeb`
- **ArweaveStorage**: `0xc7311a7c71647edd9556938ad6f22afe4dc01a66`
- **DelegationRegistry**: `0xea67b90c7d566ae98c4906fa8962844fb424e4f0`

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Deploy

```shell
forge script script/Deploy.s.sol --rpc-url polygon_amoy --broadcast --legacy
```

### Format

```shell
forge fmt
```

## Contract Architecture

- **NEWS**: Governance token with voting capabilities
- **CRED**: Reputation token earned through quality journalism
- **NewsStaking**: Staking mechanism for NEWS tokens
- **NewsDAO**: Decentralized governance for the platform
- **Verification**: News verification and credibility scoring
- **ArweaveStorage**: Integration with Arweave for permanent storage
- **DelegationRegistry**: Vote delegation system
