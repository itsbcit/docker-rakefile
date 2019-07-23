def build_objects_array(metadata_hash, build_id)
    objects_array = []

    tags        = metadata_hash['tags'].nil?        ? []         : metadata_hash['tags']
    versions    = metadata_hash['versions'].nil?    ? {'' => {}} : metadata_hash['versions']
    variants    = metadata_hash['variants'].nil?    ? {'' => {}} : metadata_hash['variants']
    registries  = metadata_hash['registries'].nil?  ? []         : metadata_hash['registries']
    labels      = metadata_hash['labels'].nil?      ? []         : metadata_hash['labels']
    vars        = metadata_hash['vars'].nil?        ? {}         : metadata_hash['vars']

    versions.keys.each do |version|
        variants.keys.each do |variant|
            objects_array << DockerImage.new(
                name: metadata_hash['image_name'],
                org_name: metadata_hash['org_name'],
                build_id: build_id,
                tags: tags,
                version: version,
                variant: variant,
                registries: registries,
                labels: labels,
                vars: vars
            )
        end
    end

    return objects_array
end
