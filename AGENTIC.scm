;; SPDX-License-Identifier: AGPL-3.0-or-later
;; AGENTIC.scm - AI agent configuration

(agentic
  (version "1.0.0")
  (model "claude-opus-4-5")

  (language-policy
    (allowed
      ("bash" "plugin scripts")
      ("shell" "utilities"))
    (banned
      ("python" "use julia or rust")
      ("typescript" "use rescript")
      ("go" "use rust"))))
