def build_objects_array(metadata_hash, build_id)
    objects_array = []

    suffixes    = metadata_hash['suffixes'].nil?    ? []         : metadata_hash['suffixes']
    versions    = metadata_hash['versions'].nil?    ? {'' => {}} : metadata_hash['versions']
    variants    = metadata_hash['variants'].nil?    ? {'' => {}} : metadata_hash['variants']
    registries  = metadata_hash['registries'].nil?  ? []         : metadata_hash['registries']
    labels      = metadata_hash['labels'].nil?      ? []         : metadata_hash['labels']
    vars        = metadata_hash['vars'].nil?        ? {}         : metadata_hash['vars']
    files       = metadata_hash['files'].nil?       ? {}         : metadata_hash['files']

    versions.each do |version, version_params|
        version_params = version_params.nil?           ? {} : version_params
        version_suffixes   = version_params['extra_suffixes'].nil?   ? [] : version_params['suffixes']
        version_files  = version_params['files'].nil?  ? [] : version_params['files']
        version_labels = version_params['labels'].nil? ? {} : version_params['labels']
        version_vars   = version_params['vars'].nil?   ? {} : version_params['vars']
        variants.each do |variant, variant_params|
            variant_params   = variant_params.nil?             ? {} : variant_params
            variant_files    = variant_params['files'].nil?    ? [] : variant_params['files']
            variant_labels   = variant_params['labels'].nil?   ? {} : variant_params['labels']
            variant_vars     = variant_params['vars'].nil?     ? {} : variant_params['vars']
            variant_suffixes = variant_params['suffixes'].nil? ? [] : variant_params['suffixes']
            objects_array << DockerImage.new(
                image_name: metadata_hash['image_name'],
                org_name: metadata_hash['org_name'],
                build_id: build_id,
                suffixes: suffixes + version_suffixes + variant_suffixes,
                version: version,
                variant: variant,
                registries: registries,
                labels: labels.merge(version_labels).merge(variant_labels),
                vars: vars,
                files: files,
            )
        end
    end

    return objects_array
end
