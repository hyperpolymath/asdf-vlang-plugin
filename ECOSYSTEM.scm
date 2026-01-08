;; SPDX-License-Identifier: AGPL-3.0-or-later
;; ECOSYSTEM.scm - Project ecosystem positioning

(ecosystem
  (version "1.0.0")
  (name "asdf-vlang-plugin")
  (type "asdf-plugin")
  (purpose "Version management for V programming language")

  (position-in-ecosystem
    (category "developer-tools")
    (subcategory "version-management")
    (layer "user-facing"))

  (related-projects
    (sibling-standard
      (name "asdf")
      (relationship "plugin-host")
      (url "https://asdf-vm.com"))
    (sibling-standard
      (name "vlang")
      (relationship "managed-tool")
      (url "https://github.com/vlang/v")))

  (what-this-is
    "An asdf plugin for managing V programming language versions")

  (what-this-is-not
    "Not a standalone version manager"
    "Not a replacement for the tool itself"))
