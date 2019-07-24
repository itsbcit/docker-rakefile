def build_objects_array(metadata, build_id)
    objects_array = []

    suffixes    = metadata['suffixes'].nil?    ? []         : metadata['suffixes']
    versions    = metadata['versions'].nil?    ? {'' => {}} : metadata['versions']
    variants    = metadata['variants'].nil?    ? {'' => {}} : metadata['variants']
    registries  = metadata['registries'].nil?  ? []         : metadata['registries']
    labels      = metadata['labels'].nil?      ? []         : metadata['labels']
    vars        = metadata['vars'].nil?        ? {}         : metadata['vars']
    files       = metadata['files'].nil?       ? {}         : metadata['files']

    versions.each do |version, version_params|
        version_params = version_params.nil?           ? {} : version_params
        version_suffixes   = version_params['suffixes'].nil?   ? [] : version_params['suffixes']
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
                image_name: metadata['image_name'],
                org_name: metadata['org_name'],
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
