# Identity and Credential Management Smart Contract

## Overview

This smart contract enables decentralized identity and credential management on the blockchain. It allows users to register and manage their identities, issue and validate credentials, and handle disclosure requests securely and efficiently. The contract ensures data integrity and security through robust validation checks and error handling.

## Features

- **Identity Management**:  
  Users can register, update, and manage their digital identities.
- **Credential Issuance**:  
  Issue, revoke, and validate user credentials with defined categories and expiration dates.
- **Disclosure Requests**:  
  Facilitate disclosure of specific identity attributes to requesting entities with approval workflows.
- **Data Validation**:  
  Built-in validation mechanisms ensure integrity and prevent unauthorized access or manipulation.

## Smart Contract Architecture

### Data Structures

1. **User Identities**:  
   Stores user-related data, including identity hash, public key, credentials, and registration timestamp.
2. **Credential Details**:  
   Stores information about issued credentials, including issuer, timestamps, categories, and revocation status.
3. **Disclosure Requests**:  
   Manages requests for identity attribute disclosures, tracking request status and associated verification proofs.

### Error Codes

- `ERROR-UNAUTHORIZED-ACCESS` (`err u100`): Unauthorized operation attempted.
- `ERROR-IDENTITY-EXISTS` (`err u101`): Identity already registered.
- `ERROR-IDENTITY-NOT-FOUND` (`err u102`): Identity not found in the system.
- `ERROR-INVALID-VERIFICATION-PROOF` (`err u103`): Submitted verification proof is invalid.
- `ERROR-CREDENTIAL-EXPIRED` (`err u104`): Credential expiration date is in the past.
- `ERROR-INVALID-INPUT` (`err u105`): Input does not meet validation requirements.

### Constants

- `MIN-TIMESTAMP`: Minimum valid timestamp (`u1`).
- `MAX-TIMESTAMP`: Maximum valid timestamp (`u9999999999`).

## Functions

### Public Functions

1. **`register-user-identity`**  
   Registers a new user identity with a public key and identity hash.

2. **`add-user-credential`**  
   Adds a credential to a user’s identity, specifying a hash, expiration timestamp, and category.

3. **`initiate-disclosure-request`**  
   Creates a new disclosure request for specific identity attributes.

4. **`approve-disclosure`**  
   Approves a disclosure request with a verification proof.

5. **`revoke-user-credential`**  
   Revokes a credential issued to a user.

6. **`update-user-identity`**  
   Updates a user’s identity with a new hash and public key.

### Read-Only Functions

1. **`get-user-identity`**  
   Retrieves identity details for a given principal.

2. **`get-credential-details`**  
   Fetches details of a credential using its hash.

3. **`verify-disclosure-request`**  
   Verifies if a disclosure request is approved with a valid proof.

4. **`check-credential-validity`**  
   Checks the validity and status of a credential.

### Private Functions

- **`validate-timestamp`**: Checks if a timestamp is within a valid range.
- **`validate-buff32`**: Ensures a buffer is exactly 32 bytes.
- **`validate-buff33`**: Ensures a buffer is exactly 33 bytes.

## Usage Guide

### Registration

To register a new identity:

```clarity
(register-user-identity user-public-key user-identity-hash)
```

### Adding Credentials

To issue a credential:

```clarity
(add-user-credential credential-hash expiration-timestamp credential-category)
```

### Handling Disclosure Requests

Initiate a disclosure request:

```clarity
(initiate-disclosure-request request-identifier required-attributes)
```

Approve a disclosure request:

```clarity
(approve-disclosure request-identifier verification-proof)
```

### Revoking Credentials

Revoke a credential:

```clarity
(revoke-user-credential credential-hash)
```

### Querying Data

Retrieve user identity:

```clarity
(get-user-identity user-principal)
```

Fetch credential details:

```clarity
(get-credential-details credential-hash)
```

### Validation

Validate disclosure requests:

```clarity
(verify-disclosure-request request-identifier submitted-proof)
```

Check credential validity:

```clarity
(check-credential-validity credential-hash)
```

## Security Considerations

- **Data Integrity**: Uses cryptographic hashes for identities and credentials.
- **Access Control**: Enforces strict ownership and permission checks.
- **Expiration Management**: Automatically handles credential expiry to prevent misuse.
- **Error Handling**: Provides descriptive error codes for debugging and contract reliability.

## Development Requirements

- **Clarity Language**: Designed for the Stacks blockchain.
- **Stacks Blockchain**: The smart contract operates on the Stacks blockchain, ensuring security and decentralization.
