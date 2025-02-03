;; PulseBeam Notifications Contract

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
