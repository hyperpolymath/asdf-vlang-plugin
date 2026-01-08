;; SPDX-License-Identifier: AGPL-3.0-or-later
;; PLAYBOOK.scm - Operational procedures

(playbook
  (version "1.0.0")

  (procedures
    (deploy
      (steps
        "tag release"
        "push to main"
        "verify CI passes"))
    (rollback
      (steps
        "revert commit"
        "push to main"))
    (debug
      (steps
        "run shellcheck"
        "test with asdf plugin test")))

  (alerts
    (ci-failure "check github actions"))

  (contacts
    (maintainer "hyperpolymath")))
