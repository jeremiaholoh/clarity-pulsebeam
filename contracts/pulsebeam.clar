;; PulseBeam Task Tracker Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-task-not-found (err u101))
(define-constant err-invalid-deadline (err u102))

;; Data Variables
(define-map tasks 
  { task-id: uint } 
  { 
    owner: principal,
    title: (string-ascii 64),
    deadline: uint,
    completed: bool,
    light-notify: bool,
    sound-notify: bool
  }
)

(define-data-var task-nonce uint u0)

;; Public Functions
(define-public (create-task (title (string-ascii 64)) (deadline uint) (light-notify bool) (sound-notify bool))
  (let
    (
      (task-id (var-get task-nonce))
    )
    (map-insert tasks
      { task-id: task-id }
      {
        owner: tx-sender,
        title: title,
        deadline: deadline,
        completed: false,
        light-notify: light-notify,
        sound-notify: sound-notify
      }
    )
    (var-set task-nonce (+ task-id u1))
    (ok task-id)
  )
)

(define-public (complete-task (task-id uint))
  (let
    (
      (task (unwrap! (map-get? tasks { task-id: task-id }) (err err-task-not-found)))
    )
    (asserts! (is-eq tx-sender (get owner task)) (err err-owner-only))
    (ok (map-set tasks
      { task-id: task-id }
      (merge task { completed: true })))
  )
)

;; Read Only Functions
(define-read-only (get-task (task-id uint))
  (ok (map-get? tasks { task-id: task-id }))
)

(define-read-only (get-user-tasks (user principal))
  (ok (map-get? tasks { owner: user }))
)
