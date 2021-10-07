# frozen_string_literal: true

# merge three arrays of registry hashes
def merge_registries(left, centre, right)
    raise "Expected Array, got #{left.class} in argument 1" unless left.is_a?(Array)
    raise "Expected Array, got #{centre.class} in argument 1" unless centre.is_a?(Array)
    raise "Expected Array, got #{right.class} in argument 2" unless right.is_a?(Array)

    registries_hash_left   = {}
    registries_hash_centre = {}
    registries_hash_right  = {}
    registries             = []

    left.each do |registry|
        registries_hash_left["#{registry['url']}/#{registry['org_name']}"] = registry
    end

    centre.each do |registry|
        registries_hash_centre["#{registry['url']}/#{registry['org_name']}"] = registry
    end

    right.each do |registry|
        registries_hash_right["#{registry['url']}/#{registry['org_name']}"] = registry
    end

    registries_merged = registries_hash_left.deep_merge(registries_hash_centre)
    registries_merged = registries_merged.deep_merge(registries_hash_right)

    registries_merged.each do |registry_org, registry|
        registries << registry
    end

    registries
end
