;; Carbon Credit Trading Contract

(define-map orders
  { order-id: uint }
  {
    seller: principal,
    amount: uint,
    price: uint,
    fulfilled: bool
  }
)

(define-data-var order-id-nonce uint u0)

(define-public (create-sell-order (amount uint) (price uint))
  (let
    (
      (order-id (+ (var-get order-id-nonce) u1))
    )
    (map-set orders
      { order-id: order-id }
      {
        seller: tx-sender,
        amount: amount,
        price: price,
        fulfilled: false
      }
    )
    (var-set order-id-nonce order-id)
    (ok order-id)
  )
)

(define-public (fulfill-order (order-id uint))
  (let
    (
      (order (unwrap! (map-get? orders { order-id: order-id }) (err u404)))
    )
    (asserts! (not (get fulfilled order)) (err u403))
    (try! (stx-transfer? (get price order) tx-sender (get seller order)))
    (ok (map-set orders
      { order-id: order-id }
      (merge order { fulfilled: true })
    ))
  )
)

(define-read-only (get-order (order-id uint))
  (ok (unwrap! (map-get? orders { order-id: order-id }) (err u404)))
)

(define-public (cancel-order (order-id uint))
  (let
    (
      (order (unwrap! (map-get? orders { order-id: order-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get seller order)) (err u403))
    (asserts! (not (get fulfilled order)) (err u403))
    (ok (map-delete orders { order-id: order-id }))
  )
)

