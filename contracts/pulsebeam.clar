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
      (current-time (unwrap! (get-block-info? time u0) (err err-invalid-deadline)))
    )
    ;; Validate deadline is in the future
    (asserts! (> deadline current-time) (err err-invalid-deadline))
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
  (let
    ((task-count (var-get task-nonce)))
    (filter tasks
      (lambda (task)
        (is-eq (get owner (get value task)) user)
      )
      task-count
    )
  )
)

(define-read-only (get-pending-tasks (user principal))
  (let
    ((task-count (var-get task-nonce)))
    (filter tasks
      (lambda (task)
        (and
          (is-eq (get owner (get value task)) user)
          (not (get completed (get value task)))
        )
      )
      task-count
    )
  )
)
