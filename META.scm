;; SPDX-License-Identifier: AGPL-3.0-or-later
;; META.scm - Meta-level project information

(meta
  (version "1.0.0")

  (architecture-decisions)

  (development-practices
    (code-style
      (shell "shellcheck" "shfmt")
      (documentation "asciidoc"))
    (security
      (scanning "trufflehog" "gitleaks")
      (scorecard "enabled"))
    (testing
      (framework "asdf-plugin-test")
      (ci-platforms "github-actions"))
    (versioning "semver")
    (documentation "README.adoc")
    (branching "trunk-based"))

  (design-rationale
    (why-asdf "Universal version manager with plugin ecosystem")
    (why-vlang "V programming language")))
