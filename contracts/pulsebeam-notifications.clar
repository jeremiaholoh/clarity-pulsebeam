;; PulseBeam Notifications Contract

(define-constant err-invalid-hours (err u200))

(define-map notification-preferences
  { user: principal }
  {
    default-light: bool,
    default-sound: bool,
    quiet-hours-start: uint,
    quiet-hours-end: uint
  }
)

(define-public (set-preferences 
  (default-light bool)
  (default-sound bool)
  (quiet-hours-start uint)
  (quiet-hours-end uint)
)
  ;; Validate quiet hours (0-23)
  (asserts! (and (< quiet-hours-start u24) (< quiet-hours-end u24)) (err err-invalid-hours))
  (ok (map-set notification-preferences
    { user: tx-sender }
    {
      default-light: default-light,
      default-sound: default-sound,
      quiet-hours-start: quiet-hours-start,
      quiet-hours-end: quiet-hours-end
    }
  ))
)

(define-read-only (get-preferences (user principal))
  (ok (map-get? notification-preferences { user: user }))
)

(define-read-only (should-notify (user principal))
  (let
    (
      (prefs (map-get? notification-preferences { user: user }))
      (current-hour (mod (unwrap! (get-block-info? time u0) u24) u24))
    )
    (if (is-none prefs)
      true
      (let
        ((quiet-start (get quiet-hours-start (unwrap-panic prefs)))
         (quiet-end (get quiet-hours-end (unwrap-panic prefs))))
        (not (and
          (>= current-hour quiet-start)
          (<= current-hour quiet-end)
        ))
      )
    )
  )
)
