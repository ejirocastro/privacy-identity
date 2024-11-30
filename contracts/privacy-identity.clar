;; title: Identity and Credential Management Smart Contract
;; summary: A smart contract for managing user identities and credentials, including registration, validation, and disclosure requests.
;; description: This smart contract allows users to register their identities and manage their credentials on the blockchain. It includes functions for registering user identities, adding credentials, initiating and approving disclosure requests, and revoking credentials. The contract also provides read-only functions to retrieve user identities and credential details, verify disclosure requests, and check credential validity. The contract ensures data integrity and security through various validation checks and error handling mechanisms.

;; Error codes
(define-constant ERROR-UNAUTHORIZED-ACCESS (err u100))
(define-constant ERROR-IDENTITY-EXISTS (err u101))
(define-constant ERROR-IDENTITY-NOT-FOUND (err u102))
(define-constant ERROR-INVALID-VERIFICATION-PROOF (err u103))
(define-constant ERROR-CREDENTIAL-EXPIRED (err u104))
(define-constant ERROR-INVALID-INPUT (err u105))

;; Constants for validation
(define-constant MIN-TIMESTAMP u1)
(define-constant MAX-TIMESTAMP u9999999999)

;; data maps
(define-map user-identities
    principal
    {
        identity-hash: (buff 32),
        registration-timestamp: uint,
        user-credentials: (list 10 (buff 32)),
        user-public-key: (buff 33),
        identity-revoked: bool
    }
)

(define-map credential-details
    (buff 32)  ;; credential hash
    {
        credential-issuer: principal,
        issuance-timestamp: uint,
        expiration-timestamp: uint,
        credential-category: (string-utf8 64),
        credential-revoked: bool
    }
)

(define-map disclosure-requests
    (buff 32)  ;; disclosure request ID
    {
        requesting-entity: principal,
        requested-attributes: (list 5 (string-utf8 64)),
        disclosure-approved: bool,
        verification-proof: (buff 32)
    }
)