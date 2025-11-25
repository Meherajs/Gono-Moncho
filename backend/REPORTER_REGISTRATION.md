# Reporter Registration and Verification System

## Overview

The Reporter Registration system implements the role-based access control described in the Gono Moncho whitepaper. It ensures that only verified reporters can publish news, while maintaining flexibility for different user roles.

## Features

### User Roles

1. **REPORTER** - Can publish news articles
   - Minimum stake: 100 NEWS tokens
   - Can publish articles after verification
   
2. **ANALYZER** - Can provide in-depth analysis
   - Minimum stake: 50 NEWS tokens
   - Can verify and analyze news articles
   
3. **VERIFIER** - Community verification role
   - Minimum stake: 25 NEWS tokens
   - Can vote on article credibility

### Reporter Status

- **NONE** - Not registered
- **PENDING** - Registered, waiting for verification
- **VERIFIED** - Approved and can publish/verify
- **REJECTED** - Application rejected
- **SUSPENDED** - Temporarily suspended by governance

## Testing Mode

The system includes a **testing mode** that allows free registration and publishing without requiring token stakes. This is enabled by default for development and testing purposes.

### Testing Mode Features

- ✅ No token staking required
- ✅ Verified reporters can publish immediately
- ✅ All roles can be tested without capital
- ✅ Can be toggled on/off by contract owner

## How It Works

### 1. Register as a Reporter

```solidity
// Register with credentials stored on IPFS
function registerReporter(
    string memory _ipfsMetadata,  // IPFS hash containing: name, credentials, proof
    UserRole _role                // REPORTER, ANALYZER, or VERIFIER
) external
```

**Example:**
```solidity
registry.registerReporter("QmYourIPFSHash", UserRole.REPORTER);
```

The IPFS metadata should contain:
- Full name
- Professional credentials
- Proof of journalism experience
- Contact information
- Portfolio/previous work

### 2. Stake Tokens (Skip in Testing Mode)

```solidity
// Approve registry to spend tokens
newsToken.approve(address(registry), 100 * 1e18);

// Stake the required amount
registry.stakeTokens(100 * 1e18);
```

**Required Stakes:**
- Reporter: 100 NEWS
- Analyzer: 50 NEWS  
- Verifier: 25 NEWS

### 3. Get Verified

An authorized verifier (initially admin, later DAO) reviews your credentials and approves:

```solidity
registry.verifyReporter(reporterAddress, true); // true = approve, false = reject
```

### 4. Publish News

Once verified, you can publish articles:

```solidity
verification.publishNews("QmArweaveHashOfYourArticle");
```

The system automatically checks:
- ✅ Are you a verified reporter?
- ✅ Do you have sufficient stake? (if not in testing mode)
- ✅ Are you not suspended?

## Contract Functions

### For Users

#### `registerReporter(string memory _ipfsMetadata, UserRole _role)`
Register as a reporter with your credentials.

#### `stakeTokens(uint256 _amount)`
Stake NEWS tokens to meet role requirements.

#### `withdrawStake(uint256 _amount)`
Withdraw staked tokens (must maintain minimum stake).

#### `getReporterProfile(address _reporter)`
Get complete profile information for a reporter.

#### `canPublish(address _user)`
Check if an address can publish news.

#### `canVerify(address _user)`
Check if an address can verify news.

### For Admins/DAO

#### `verifyReporter(address _reporter, bool _approve)`
Approve or reject a pending reporter application.

#### `suspendReporter(address _reporter)`
Temporarily suspend a reporter (governance action).

#### `reinstateReporter(address _reporter)`
Reinstate a suspended reporter.

#### `setTestingMode(bool _enabled)`
Enable/disable testing mode.

#### `addVerifier(address _verifier)`
Add an authorized verifier.

#### `removeVerifier(address _verifier)`
Remove an authorized verifier.

## Integration with Verification Contract

The `Verification` contract now checks permissions before allowing actions:

```solidity
// Publishing requires reporter verification
function publishNews(string memory contentHash) external {
    require(
        reporterRegistry.canPublish(msg.sender),
        "Not authorized to publish"
    );
    // ... publish logic
}

// Verification requires analyzer/verifier role
function addVerifierScore(string memory contentHash, uint256 score) external {
    require(
        reporterRegistry.canVerify(msg.sender),
        "Not authorized to verify"
    );
    // ... verification logic
}
```

## Deployment

The ReporterRegistry is deployed as part of the main deployment script:

```bash
forge script script/Deploy.s.sol --rpc-url polygon_amoy --broadcast --legacy
```

Contract addresses after deployment:
- ReporterRegistry: [Will be shown after deployment]

## Testing

Run the comprehensive test suite:

```bash
# Run all reporter registry tests
forge test --match-contract ReporterRegistryTest -vv

# Run specific test
forge test --match-test testRegisterReporter -vvv
```

## Security Considerations

### Stake Slashing
Future implementation will include:
- Automatic stake slashing for publishing fake news
- Reputation penalties for malicious verification
- Appeal mechanism through DAO governance

### Privacy
- IPFS metadata can be encrypted
- On-chain data only stores hashes
- ZK-proofs for anonymous publishing (future)

### Governance
- Verification authority will transition to DAO
- Community can vote to suspend malicious actors
- Transparent on-chain record of all actions

## Future Enhancements

1. **Reputation System** - Track historical accuracy and credibility
2. **Tiered Access** - Different publishing limits based on reputation
3. **Delegation** - Newsrooms can stake for their journalists
4. **Appeals Process** - DAO-governed appeals for rejected/suspended reporters
5. **ZK-Proof Integration** - Prove credentials without revealing identity

## Example Usage Flow

```solidity
// 1. User registers as reporter
registry.registerReporter("QmCredentials", UserRole.REPORTER);

// 2. In testing mode, admin verifies immediately (no stake needed)
registry.verifyReporter(userAddress, true);

// 3. User can now publish
verification.publishNews("QmArticleHash");

// 4. When testing mode is off:
//    - User must stake 100 NEWS tokens first
//    - Then get verified
//    - Then can publish
```

## Contract Addresses (Polygon Amoy Testnet)

After deployment, update these addresses:

```
ReporterRegistry: [To be deployed]
Verification: 0xe5672b7bf38e11d81feb07d77a35cf5499a0adeb (needs upgrade)
NEWS Token: 0xd3091433da9a925c38682b28ffbae975ed06617a
```

## Gas Estimates

- Register reporter: ~120,000 gas
- Stake tokens: ~70,000 gas
- Verify reporter: ~50,000 gas
- Check permissions: ~5,000 gas (view function)

## Questions?

For more information, refer to:
- [Gono Moncho Whitepaper](../Gono-Moncho-A-Decentralized-Sybil-resistant-Ecosystem-for-Verifiable-Journalism-with-Privacy-Preserving-Cryptographic-Proofs.txt)
- [Usage Guide](../USAGE.md)
- [Main README](../README.md)
