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

;; public functions

;; Registers a new user identity with the provided public key and identity hash
(define-public (register-user-identity 
    (user-public-key (buff 33)) 
    (user-identity-hash (buff 32)))
    (let
        ((current-user tx-sender))
        (asserts! (validate-buff33 user-public-key) ERROR-INVALID-INPUT)
        (asserts! (validate-buff32 user-identity-hash) ERROR-INVALID-INPUT)
        (asserts! (is-none (map-get? user-identities current-user)) ERROR-IDENTITY-EXISTS)
        (ok (map-set user-identities
            current-user
            {
                identity-hash: user-identity-hash,
                registration-timestamp: block-height,
                user-credentials: (list),
                user-public-key: user-public-key,
                identity-revoked: false
            }
        ))
    )
)

;; Adds a new credential for the user with the specified hash, expiration timestamp, and category
(define-public (add-user-credential 
    (credential-hash (buff 32))
    (expiration-timestamp uint)
    (credential-category (string-utf8 64)))
    (let
        ((current-user tx-sender)
         (user-identity (unwrap! (map-get? user-identities current-user) ERROR-IDENTITY-NOT-FOUND)))
        (asserts! (validate-buff32 credential-hash) ERROR-INVALID-INPUT)
        (asserts! (validate-timestamp expiration-timestamp) ERROR-INVALID-INPUT)
        (asserts! (> expiration-timestamp block-height) ERROR-CREDENTIAL-EXPIRED)
        (asserts! (not (get identity-revoked user-identity)) ERROR-UNAUTHORIZED-ACCESS)
        (map-set credential-details
            credential-hash
            {
                credential-issuer: current-user,
                issuance-timestamp: block-height,
                expiration-timestamp: expiration-timestamp,
                credential-category: credential-category,
                credential-revoked: false
            }
        )
        (ok (map-set user-identities
            current-user
            (merge user-identity
                {user-credentials: (unwrap! (as-max-len? (append (get user-credentials user-identity) credential-hash) u10)
                    ERROR-UNAUTHORIZED-ACCESS)}
            )
        ))
    )
)

;; Initiates a disclosure request with the specified identifier and required attributes
(define-public (initiate-disclosure-request
    (request-identifier (buff 32))
    (required-attributes (list 5 (string-utf8 64))))
    (let
        ((requesting-user tx-sender))
        (asserts! (validate-buff32 request-identifier) ERROR-INVALID-INPUT)
        (asserts! (not (is-none (map-get? disclosure-requests request-identifier))) ERROR-INVALID-INPUT)
        (ok (map-set disclosure-requests
            request-identifier
            {
                requesting-entity: requesting-user,
                requested-attributes: required-attributes,
                disclosure-approved: false,
                verification-proof: 0x00
            }
        ))
    )
)

;; Approves a disclosure request with the specified identifier and verification proof
(define-public (approve-disclosure
    (request-identifier (buff 32))
    (verification-proof (buff 32)))
    (let
        ((current-user tx-sender)
         (disclosure-request (unwrap! (map-get? disclosure-requests request-identifier) ERROR-UNAUTHORIZED-ACCESS))
         (user-identity (unwrap! (map-get? user-identities current-user) ERROR-IDENTITY-NOT-FOUND)))
        (asserts! (validate-buff32 request-identifier) ERROR-INVALID-INPUT)
        (asserts! (validate-buff32 verification-proof) ERROR-INVALID-INPUT)
        (asserts! (not (get identity-revoked user-identity)) ERROR-UNAUTHORIZED-ACCESS)
        (asserts! (validate-verification-proof verification-proof (get identity-hash user-identity)) ERROR-INVALID-VERIFICATION-PROOF)
        (ok (map-set disclosure-requests
            request-identifier
            (merge disclosure-request
                {
                    disclosure-approved: true,
                    verification-proof: verification-proof
                }
            )
        ))
    )
)

;; Revokes a user credential with the specified hash
(define-public (revoke-user-credential (credential-hash (buff 32)))
    (let
        ((current-user tx-sender)
         (credential-info (unwrap! (map-get? credential-details credential-hash) ERROR-UNAUTHORIZED-ACCESS)))
        (asserts! (validate-buff32 credential-hash) ERROR-INVALID-INPUT)
        (asserts! (is-eq (get credential-issuer credential-info) current-user) ERROR-UNAUTHORIZED-ACCESS)
        (ok (map-set credential-details
            credential-hash
            (merge credential-info {credential-revoked: true})
        ))
    )
)