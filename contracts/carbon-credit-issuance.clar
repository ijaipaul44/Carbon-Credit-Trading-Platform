;; Carbon Credit Issuance and Verification Contract

(define-map verified-projects
  { project-id: uint }
  {
    owner: principal,
    name: (string-utf8 100),
    description: (string-utf8 500),
    verified: bool
  }
)

(define-map emissions-data
  { project-id: uint, timestamp: uint }
  { emissions-reduced: uint }
)

(define-data-var project-id-nonce uint u0)

(define-public (register-project (name (string-utf8 100)) (description (string-utf8 500)))
  (let
    (
      (new-project-id (+ (var-get project-id-nonce) u1))
    )
    (map-set verified-projects
      { project-id: new-project-id }
      {
        owner: tx-sender,
        name: name,
        description: description,
        verified: false
      }
    )
    (var-set project-id-nonce new-project-id)
    (ok new-project-id)
  )
)

(define-public (verify-project (project-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (match (map-get? verified-projects { project-id: project-id })
      project (ok (map-set verified-projects
        { project-id: project-id }
        (merge project { verified: true })))
      (err u404)
    )
  )
)

(define-public (submit-emissions-data (project-id uint) (emissions-reduced uint))
  (let
    (
      (project (unwrap! (map-get? verified-projects { project-id: project-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner project)) (err u403))
    (asserts! (get verified project) (err u403))
    (ok (map-set emissions-data
      { project-id: project-id, timestamp: block-height }
      { emissions-reduced: emissions-reduced }
    ))
  )
)

(define-read-only (get-project (project-id uint))
  (ok (unwrap! (map-get? verified-projects { project-id: project-id }) (err u404)))
)

(define-read-only (get-emissions-data (project-id uint) (timestamp uint))
  (ok (unwrap! (map-get? emissions-data { project-id: project-id, timestamp: timestamp }) (err u404)))
)

(define-data-var contract-owner principal tx-sender)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (var-set contract-owner new-owner))
  )
)

