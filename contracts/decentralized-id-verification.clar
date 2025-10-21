(define-constant ERR_UNAUTHORIZED u401)
(define-constant ERR_IDENTITY_NOT_FOUND u402)
(define-constant ERR_ALREADY_VERIFIED u403)
(define-constant ERR_INVALID_VERIFICATION u404)
(define-constant ERR_INSUFFICIENT_ATTESTATIONS u405)
(define-constant ERR_EXPIRED_VERIFICATION u406)
(define-constant ERR_INVALID_VERIFIER u407)
(define-constant ERR_ALREADY_ATTESTED u408)
(define-constant ERR_INVALID_DOCUMENT u409)
(define-constant ERR_VERIFICATION_PENDING u410)

(define-constant VERIFICATION_STATUS_PENDING u0)
(define-constant VERIFICATION_STATUS_VERIFIED u1)
(define-constant VERIFICATION_STATUS_REJECTED u2)
(define-constant VERIFICATION_STATUS_EXPIRED u3)

(define-constant DOCUMENT_TYPE_PASSPORT u0)
(define-constant DOCUMENT_TYPE_DRIVERS_LICENSE u1)
(define-constant DOCUMENT_TYPE_NATIONAL_ID u2)
(define-constant DOCUMENT_TYPE_BIRTH_CERTIFICATE u3)

(define-constant VERIFICATION_VALIDITY_PERIOD u525600)
(define-constant MIN_ATTESTATIONS_REQUIRED u3)
(define-constant VERIFICATION_FEE u500000)

(define-data-var identity-counter uint u0)
(define-data-var verifier-counter uint u0)
(define-data-var total-verification-fees uint u0)
(define-data-var contract-owner principal tx-sender)

(define-map identities principal {
    identity-id: uint,
    name-hash: (string-ascii 64),
    document-hash: (string-ascii 64),
    document-type: uint,
    verification-status: uint,
    verification-date: uint,
    expiry-date: uint,
    verifier: (optional principal),
    attestation-count: uint,
    reputation-score: uint
})

(define-map verifiers principal {
    verifier-id: uint,
    name: (string-ascii 100),
    verification-type: uint,
    total-verifications: uint,
    successful-verifications: uint,
    reputation-score: uint,
    is-active: bool,
    registration-date: uint
})

(define-map attestations { identity: principal, attester: principal } {
    attestation-date: uint,
    document-verified: bool,
    identity-verified: bool,
    notes: (string-ascii 200),
    confidence-score: uint
})

(define-map verification-requests uint {
    requester: principal,
    document-hash: (string-ascii 64),
    document-type: uint,
    request-date: uint,
    assigned-verifier: (optional principal),
    status: uint
})

(define-map identity-credentials principal {
    credentials: (list 10 (string-ascii 50)),
    issuer: principal,
    issue-date: uint,
    validity-period: uint
})

(define-map verifier-approvals principal {
    approved-by: principal,
    approval-date: uint,
    verification-types: (list 5 uint)
})

(define-public (register-identity (name-hash (string-ascii 64)) (document-hash (string-ascii 64)) (document-type uint))
    (let (
        (identity-id (+ (var-get identity-counter) u1))
        (current-date burn-block-height)
    )
        (asserts! (is-none (map-get? identities tx-sender)) (err ERR_ALREADY_VERIFIED))
        (asserts! (<= document-type DOCUMENT_TYPE_BIRTH_CERTIFICATE) (err ERR_INVALID_DOCUMENT))
        
        (try! (stx-transfer? VERIFICATION_FEE tx-sender (as-contract tx-sender)))
        
        (map-set identities tx-sender {
            identity-id: identity-id,
            name-hash: name-hash,
            document-hash: document-hash,
            document-type: document-type,
            verification-status: VERIFICATION_STATUS_PENDING,
            verification-date: current-date,
            expiry-date: (+ current-date VERIFICATION_VALIDITY_PERIOD),
            verifier: none,
            attestation-count: u0,
            reputation-score: u0
        })
        
        (var-set identity-counter identity-id)
        (var-set total-verification-fees (+ (var-get total-verification-fees) VERIFICATION_FEE))
        (ok identity-id)
    )
)

(define-public (register-verifier (name (string-ascii 100)) (verification-type uint))
    (let (
        (verifier-id (+ (var-get verifier-counter) u1))
    )
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
        (asserts! (is-none (map-get? verifiers tx-sender)) (err ERR_ALREADY_VERIFIED))
        
        (map-set verifiers tx-sender {
            verifier-id: verifier-id,
            name: name,
            verification-type: verification-type,
            total-verifications: u0,
            successful-verifications: u0,
            reputation-score: u100,
            is-active: true,
            registration-date: burn-block-height
        })
        
        (var-set verifier-counter verifier-id)
        (ok verifier-id)
    )
)

(define-public (verify-identity (identity-principal principal) (verification-result bool) (notes (string-ascii 200)))
    (let (
        (identity (unwrap! (map-get? identities identity-principal) (err ERR_IDENTITY_NOT_FOUND)))
        (verifier-info (unwrap! (map-get? verifiers tx-sender) (err ERR_INVALID_VERIFIER)))
    )
        (asserts! (get is-active verifier-info) (err ERR_INVALID_VERIFIER))
        (asserts! (is-eq (get verification-status identity) VERIFICATION_STATUS_PENDING) (err ERR_ALREADY_VERIFIED))
        
        (map-set identities identity-principal (merge identity {
            verification-status: (if verification-result VERIFICATION_STATUS_VERIFIED VERIFICATION_STATUS_REJECTED),
            verifier: (some tx-sender),
            reputation-score: (if verification-result u100 u0)
        }))
        
        (map-set verifiers tx-sender (merge verifier-info {
            total-verifications: (+ (get total-verifications verifier-info) u1),
            successful-verifications: (if verification-result 
                                        (+ (get successful-verifications verifier-info) u1)
                                        (get successful-verifications verifier-info))
        }))
        
        (ok verification-result)
    )
)

(define-public (attest-identity (identity-principal principal) (document-verified bool) (identity-verified bool) (notes (string-ascii 200)) (confidence-score uint))
    (let (
        (identity (unwrap! (map-get? identities identity-principal) (err ERR_IDENTITY_NOT_FOUND)))
    )
        (asserts! (is-some (map-get? verifiers tx-sender)) (err ERR_INVALID_VERIFIER))
        (asserts! (is-none (map-get? attestations { identity: identity-principal, attester: tx-sender })) (err ERR_ALREADY_ATTESTED))
        (asserts! (<= confidence-score u100) (err ERR_INVALID_VERIFICATION))
        
        (map-set attestations { identity: identity-principal, attester: tx-sender } {
            attestation-date: burn-block-height,
            document-verified: document-verified,
            identity-verified: identity-verified,
            notes: notes,
            confidence-score: confidence-score
        })
        
        (map-set identities identity-principal (merge identity {
            attestation-count: (+ (get attestation-count identity) u1)
        }))
        
        (ok true)
    )
)

(define-public (revoke-verification (identity-principal principal))
    (let (
        (identity (unwrap! (map-get? identities identity-principal) (err ERR_IDENTITY_NOT_FOUND)))
        (verifier-info (unwrap! (map-get? verifiers tx-sender) (err ERR_INVALID_VERIFIER)))
    )
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get verification-status identity) VERIFICATION_STATUS_VERIFIED) (err ERR_INVALID_VERIFICATION))
        
        (map-set identities identity-principal (merge identity {
            verification-status: VERIFICATION_STATUS_REJECTED,
            reputation-score: u0
        }))
        
        (ok true)
    )
)

(define-public (renew-verification)
    (let (
        (identity (unwrap! (map-get? identities tx-sender) (err ERR_IDENTITY_NOT_FOUND)))
        (renewal-fee (/ VERIFICATION_FEE u2))
    )
        (asserts! (is-eq (get verification-status identity) VERIFICATION_STATUS_VERIFIED) (err ERR_INVALID_VERIFICATION))
        (asserts! (>= burn-block-height (get expiry-date identity)) (err ERR_VERIFICATION_PENDING))
        
        (try! (stx-transfer? renewal-fee tx-sender (as-contract tx-sender)))
        
        (map-set identities tx-sender (merge identity {
            expiry-date: (+ burn-block-height VERIFICATION_VALIDITY_PERIOD),
            verification-date: burn-block-height
        }))
        
        (var-set total-verification-fees (+ (var-get total-verification-fees) renewal-fee))
        (ok true)
    )
)

(define-public (update-reputation (identity-principal principal) (new-score uint))
    (let (
        (identity (unwrap! (map-get? identities identity-principal) (err ERR_IDENTITY_NOT_FOUND)))
    )
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
        (asserts! (<= new-score u100) (err ERR_INVALID_VERIFICATION))
        
        (map-set identities identity-principal (merge identity { reputation-score: new-score }))
        (ok true)
    )
)

(define-public (deactivate-verifier (verifier-principal principal))
    (let (
        (verifier-info (unwrap! (map-get? verifiers verifier-principal) (err ERR_INVALID_VERIFIER)))
    )
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
        
        (map-set verifiers verifier-principal (merge verifier-info { is-active: false }))
        (ok true)
    )
)

(define-public (issue-credential (recipient principal) (credential-type (string-ascii 50)))
    (let (
        (existing-creds (default-to { credentials: (list), issuer: tx-sender, issue-date: burn-block-height, validity-period: VERIFICATION_VALIDITY_PERIOD }
                        (map-get? identity-credentials recipient)))
        (identity (unwrap! (map-get? identities recipient) (err ERR_IDENTITY_NOT_FOUND)))
    )
        (asserts! (is-some (map-get? verifiers tx-sender)) (err ERR_INVALID_VERIFIER))
        (asserts! (is-eq (get verification-status identity) VERIFICATION_STATUS_VERIFIED) (err ERR_INVALID_VERIFICATION))
        
        (map-set identity-credentials recipient (merge existing-creds {
            credentials: (unwrap! (as-max-len? (append (get credentials existing-creds) credential-type) u10) (err ERR_INVALID_VERIFICATION)),
            issuer: tx-sender,
            issue-date: burn-block-height
        }))
        
        (ok true)
    )
)

(define-read-only (get-identity (identity-principal principal))
    (map-get? identities identity-principal)
)

(define-read-only (get-verifier (verifier-principal principal))
    (map-get? verifiers verifier-principal)
)

(define-read-only (get-attestation (identity-principal principal) (attester principal))
    (map-get? attestations { identity: identity-principal, attester: attester })
)

(define-read-only (get-credentials (identity-principal principal))
    (map-get? identity-credentials identity-principal)
)

(define-read-only (is-identity-verified (identity-principal principal))
    (match (map-get? identities identity-principal)
        identity (and 
                    (is-eq (get verification-status identity) VERIFICATION_STATUS_VERIFIED)
                    (< burn-block-height (get expiry-date identity)))
        false
    )
)

(define-read-only (is-verifier-active (verifier-principal principal))
    (match (map-get? verifiers verifier-principal)
        verifier (get is-active verifier)
        false
    )
)

(define-read-only (get-identity-reputation (identity-principal principal))
    (match (map-get? identities identity-principal)
        identity (get reputation-score identity)
        u0
    )
)

(define-read-only (get-verifier-stats (verifier-principal principal))
    (match (map-get? verifiers verifier-principal)
        verifier (some {
            success-rate: (if (> (get total-verifications verifier) u0)
                            (/ (* (get successful-verifications verifier) u100) (get total-verifications verifier))
                            u0),
            total-verifications: (get total-verifications verifier),
            reputation: (get reputation-score verifier),
            is-active: (get is-active verifier)
        })
        none
    )
)

(define-read-only (get-identity-validity (identity-principal principal))
    (match (map-get? identities identity-principal)
        identity (some {
            is-valid: (< burn-block-height (get expiry-date identity)),
            days-until-expiry: (if (> (get expiry-date identity) burn-block-height)
                                 (/ (- (get expiry-date identity) burn-block-height) u144)
                                 u0),
            verification-status: (get verification-status identity),
            attestation-count: (get attestation-count identity)
        })
        none
    )
)

(define-read-only (get-contract-stats)
    {
        total-identities: (var-get identity-counter),
        total-verifiers: (var-get verifier-counter),
        total-fees-collected: (var-get total-verification-fees),
        contract-owner: (var-get contract-owner)
    }
)