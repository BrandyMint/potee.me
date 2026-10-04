# Release version (semver), kept in VERSION and bumped by bin/release.
module Potee
  VERSION = Rails.root.join("VERSION").read.strip.freeze
end
