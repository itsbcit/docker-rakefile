# frozen_string_literal: true

# add string method to detect public registry URLs
class String
  def contains_public_registry?
    public_registries = [
      'bintray.io',
      'docker.io',
      'ghcr.io',
      'quay.io',
    ]

    found = false
    for reg in public_registries do
      found = true if self.include? reg
    end

    found
  end
end
