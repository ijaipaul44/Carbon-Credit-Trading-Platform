;; Carbon Credit Token Contract

(define-fungible-token carbon-credit)

(define-data-var token-uri (string-utf8 256) u"")

(define-public (set-token-uri (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (var-set token-uri uri))
  )
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ft-mint? carbon-credit amount recipient)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (ft-transfer? carbon-credit amount sender recipient)
  )
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance carbon-credit account))
)

(define-data-var contract-owner principal tx-sender)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (var-set contract-owner new-owner))
  )
)

