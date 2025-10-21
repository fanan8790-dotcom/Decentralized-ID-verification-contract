# 🆔 Decentralized ID Verification Contract

A comprehensive blockchain-based identity verification system built on the Stacks blockchain, enabling secure, decentralized identity management through cryptographic verification, attestations, and reputation-based trust networks.

## 🚀 Features

- **Identity Registration** 📋: Secure registration with cryptographic document hashes and identity verification
- **Multi-Type Verification** ✅: Support for passports, driver's licenses, national IDs, and birth certificates
- **Verifier Network** 👥: Decentralized network of trusted verifiers with reputation tracking
- **Attestation System** 📜: Peer attestations with confidence scoring and verification notes
- **Reputation Management** ⭐: Reputation scoring for both identities and verifiers
- **Credential Issuance** 🎫: Issue and manage digital credentials for verified identities
- **Automatic Expiry** ⏰: Time-based verification expiry with renewal capabilities
- **Privacy Protection** 🔐: Hash-based identity storage for enhanced privacy

## 📁 Project Structure

```
Decentralized-ID-verification-contract/
├── contracts/
│   └── decentralized-id-verification.clar    # Main smart contract
├── tests/
│   └── decentralized-id-verification.test.ts # TypeScript tests
├── Clarinet.toml                             # Project configuration
└── README.md                                 # This file
```

## 🛠️ Installation & Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) (for testing)

### Quick Start
```bash
# Clone the repository
git clone <your-repo-url>
cd Decentralized-ID-verification-contract

# Check contract syntax
clarinet check

# Run tests
npm install
npm test

# Start local development network
clarinet integrate
```

## 📖 Contract Functions

### Public Functions

#### Identity Management
- `register-identity` - Register new identity with document hash and verification fee
- `verify-identity` - Official verification by authorized verifiers
- `renew-verification` - Extend verification validity period
- `revoke-verification` - Admin revocation of verified identities

#### Verifier Operations
- `register-verifier` - Register new verifier (admin only)
- `deactivate-verifier` - Disable verifier access (admin only)
- `attest-identity` - Provide attestations for identity verification

#### Credential System
- `issue-credential` - Issue digital credentials to verified identities
- `update-reputation` - Admin reputation score updates

### Read-Only Functions
- `get-identity` - Retrieve complete identity information and status
- `get-verifier` - View verifier details and statistics
- `get-attestation` - Access specific attestation records
- `get-credentials` - View issued credentials for an identity
- `is-identity-verified` - Check if identity is currently verified and valid
- `is-verifier-active` - Verify if a verifier is currently active
- `get-identity-reputation` - Get reputation score for an identity
- `get-verifier-stats` - Access verifier performance statistics
- `get-identity-validity` - Check identity validity and expiry information
- `get-contract-stats` - Platform-wide statistics and metrics

## 🎯 Usage Examples

### Registering an Identity
```clarity
(contract-call? .decentralized-id-verification register-identity
  "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"  ;; Name hash
  "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"  ;; Document hash
  u0  ;; Passport document type
)
```

### Registering a Verifier (Admin Only)
```clarity
(contract-call? .decentralized-id-verification register-verifier
  "Global Identity Verification Services"  ;; Verifier name
  u0  ;; Verification type
)
```

### Verifying an Identity
```clarity
(contract-call? .decentralized-id-verification verify-identity
  'SP-IDENTITY-PRINCIPAL-ADDRESS  ;; Identity to verify
  true                            ;; Verification result
  "Identity verified through comprehensive document analysis and biometric validation"
)
```

### Attesting an Identity
```clarity
(contract-call? .decentralized-id-verification attest-identity
  'SP-IDENTITY-PRINCIPAL-ADDRESS  ;; Identity to attest
  true                            ;; Document verified
  true                            ;; Identity verified
  "Confirmed identity through secondary verification process"  ;; Notes
  u85                             ;; 85% confidence score
)
```

### Issuing Credentials
```clarity
(contract-call? .decentralized-id-verification issue-credential
  'SP-RECIPIENT-PRINCIPAL-ADDRESS  ;; Credential recipient
  "KYC-Verified"                   ;; Credential type
)
```

### Renewing Verification
```clarity
(contract-call? .decentralized-id-verification renew-verification)
```

### Revoking Verification (Admin Only)
```clarity
(contract-call? .decentralized-id-verification revoke-verification
  'SP-IDENTITY-PRINCIPAL-ADDRESS  ;; Identity to revoke
)
```

## 📊 Verification Status Flow

```
PENDING (0) → Verification Process → VERIFIED (1)
     ↓                                      ↓
REJECTED (2)                           EXPIRED (3)
```

## 📄 Document Types Supported

```
PASSPORT (0)           - International passport documents
DRIVERS_LICENSE (1)    - Driver's license verification
NATIONAL_ID (2)        - National identity cards
BIRTH_CERTIFICATE (3) - Birth certificate validation
```

## 💼 Business Model

### Fee Structure
- **Verification Fee**: 0.5 STX for initial identity registration
- **Renewal Fee**: 0.25 STX for verification renewal (50% of original fee)
- **Verifier Registration**: Admin-controlled, no fee for authorized verifiers
- **Credential Issuance**: Free for verified identities

### Validity Periods
- **Verification Duration**: 525,600 blocks (~365 days)
- **Renewal Period**: Additional 525,600 blocks per renewal
- **Attestation Validity**: Permanent record with timestamp tracking

## 🔒 Security Features

- **Hash-Based Privacy**: Identity and document data stored as cryptographic hashes
- **Admin Controls**: Contract owner manages verifier registration and revocations
- **Verifier Authorization**: Only registered, active verifiers can perform verifications
- **Automatic Expiry**: Time-based verification expiry prevents outdated verifications
- **Attestation Limits**: One attestation per verifier prevents spam
- **Reputation Tracking**: Reputation scores for fraud prevention and trust building
- **Fee Protection**: STX fees prevent spam registrations

## 💡 Use Cases

### Financial Services
- **KYC Compliance**: Know Your Customer verification for financial institutions
- **Account Opening**: Streamlined account creation with verified identities
- **Loan Verification**: Identity verification for lending platforms
- **Investment Platforms**: Verified investor status for securities trading

### Digital Services
- **Platform Registration**: Verified user accounts for social platforms
- **Age Verification**: Age-restricted content and services
- **Professional Verification**: Credential verification for professional networks
- **Healthcare Access**: Identity verification for telemedicine and health services

### Government Services
- **Digital Identity**: Government-issued digital identity credentials
- **Voting Systems**: Voter identity verification for digital voting
- **Benefits Distribution**: Identity verification for social benefit programs
- **Border Control**: Digital identity for travel and immigration

## 🎨 User Benefits

- **Privacy Protection** 🔐: Hash-based storage ensures personal data privacy
- **Global Accessibility** 🌍: Decentralized verification accessible worldwide
- **Permanent Records** 📚: Immutable blockchain record of verification history
- **Multi-Verifier Trust** 🤝: Multiple verifier attestations increase trust
- **Credential Portability** 🎒: Digital credentials usable across platforms
- **Automated Renewal** 🔄: Simple renewal process for extended validity
- **Reputation Building** 📈: Build trust through verified identity history

## 📈 Platform Analytics

The contract provides comprehensive analytics:
- **Identity Statistics**: Track registration and verification rates
- **Verifier Performance**: Monitor verifier success rates and reputation
- **Attestation Metrics**: Analyze attestation patterns and confidence scores
- **Revenue Tracking**: Monitor platform fee collection and usage
- **Expiry Management**: Track verification expiry and renewal rates
- **Geographic Distribution**: Understand global platform adoption

## 🧪 Testing

Run the comprehensive test suite:

```bash
npm install
npm test
```

Tests cover:
- Identity registration and verification workflows
- Verifier registration and management
- Attestation system functionality
- Credential issuance and management
- Reputation system operations
- Renewal and expiry handling
- Admin controls and security features
- Error handling and edge cases

## 🚦 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 401 | ERR_UNAUTHORIZED | Access denied for operation |
| 402 | ERR_IDENTITY_NOT_FOUND | Identity record doesn't exist |
| 403 | ERR_ALREADY_VERIFIED | Identity already verified or verifier exists |
| 404 | ERR_INVALID_VERIFICATION | Invalid verification parameters |
| 405 | ERR_INSUFFICIENT_ATTESTATIONS | Not enough attestations for verification |
| 406 | ERR_EXPIRED_VERIFICATION | Verification has expired |
| 407 | ERR_INVALID_VERIFIER | Verifier not found or inactive |
| 408 | ERR_ALREADY_ATTESTED | Verifier already provided attestation |
| 409 | ERR_INVALID_DOCUMENT | Invalid document type specified |
| 410 | ERR_VERIFICATION_PENDING | Verification process still pending |

## 🌟 Platform Benefits

- **Decentralized Trust** 🏛️: No single authority controls identity verification
- **Global Interoperability** 🌐: Cross-platform identity verification standard
- **Cost Efficiency** 💸: Lower costs compared to traditional verification systems
- **Fraud Prevention** 🛡️: Reputation-based system reduces fraudulent verifications
- **Regulatory Compliance** 📋: Meets KYC/AML requirements for regulated industries
- **Scalable Architecture** 📊: Blockchain infrastructure supports global scale
- **Transparency** 🔍: All verification activities publicly auditable

## 🎯 Target Markets

- **Financial Technology**: Fintech companies requiring KYC compliance
- **Healthcare Platforms**: Telemedicine and health service providers
- **Government Agencies**: Digital identity and citizen service providers
- **Education Sector**: Academic credential verification systems
- **Travel Industry**: Identity verification for travel and hospitality
- **E-commerce**: Age verification and trusted seller programs
- **Social Platforms**: Verified user account systems

## 🌟 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add comprehensive tests
5. Run `clarinet check` to validate
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🤝 Support

For questions or support:
- Create an issue on GitHub
- Check the [Stacks documentation](https://docs.stacks.co/)
- Visit the [Clarinet documentation](https://docs.hiro.so/stacks/clarinet-js-sdk)

## 🚀 Deployment

Ready for deployment on:
- **Stacks Testnet**: For testing and development
- **Stacks Mainnet**: For production identity verification

---

Built with ❤️ for secure and decentralized identity verification using Stacks blockchain technology.
