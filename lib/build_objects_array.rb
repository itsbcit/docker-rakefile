# frozen_string_literal: true

def build_objects_array(options = {})
  metadata         = options.fetch(:metadata, {})
  default_metadata = options.fetch(:default_metadata, {})

  objects_array = []

  image_name     = metadata['image_name']
  template_files = metadata['template_files'].nil? ? []           : metadata['template_files']
  labels         = metadata['labels'].nil?         ? []           : metadata['labels']
  maintainer     = metadata['maintainer'].nil?     ? ''           : metadata['maintainer']
  registries     = metadata['registries'].nil?     ? []           : metadata['registries']
  tags           = metadata['tags'].nil?           ? []           : metadata['tags']
  variants       = metadata['variants'].nil?       ? { '' => {} } : metadata['variants']
  vars           = metadata['vars'].nil?           ? {}           : metadata['vars']
  versions       = metadata['versions'].nil?       ? { '' => {} } : metadata['versions']

  versions.each do |version, version_params|
    version_params         = version_params.nil?                   ? {} : version_params
    version_template_files = version_params['template_files'].nil? ? [] : version_params['template_files']
    version_labels         = version_params['labels'].nil?         ? [] : version_params['labels']
    version_registries     = version_params['registries'].nil?     ? [] : version_params['registries']
    version_tags           = version_params['tags'].nil?           ? [] : version_params['tags']
    version_variants       = version_params['variants'].nil?       ? [] : version_params['variants']
    version_vars           = version_params['vars'].nil?           ? {} : version_params['vars']

    maintainer = version_params['maintainer'].nil? ? maintainer : version_params['maintainer'].nil?
    variants   = variants.deep_merge(version_variants)

    variants.each do |variant, variant_params|
      variant_params         = variant_params.nil?                   ? {} : variant_params
      variant_template_files = variant_params['template_files'].nil? ? [] : variant_params['template_files']
      variant_labels         = variant_params['labels'].nil?         ? {} : variant_params['labels']
      variant_registries     = variant_params['registries'].nil?     ? [] : variant_params['registries']
      variant_tags           = variant_params['tags'].nil?           ? [] : variant_params['tags']
      variant_vars           = variant_params['vars'].nil?           ? {} : variant_params['vars']

      merged_registries = merge_registries(registries, version_registries, variant_registries)
      merged_registries = merged_registries.empty? ? [{ url: '', org_name: '' }] : merged_registries

      objects_array << DockerImage.new(
        image_name:     image_name,
        variant:        variant,
        version:        version,
        template_files: (template_files + version_template_files + variant_template_files).uniq,
        tags:           (tags + version_tags + variant_tags).uniq,
        registries:     merged_registries,
        labels:         labels.deep_merge(version_labels).deep_merge(variant_labels),
        maintainer:     maintainer,
        vars:           vars.deep_merge(version_vars).deep_merge(variant_vars),
      )
    end
  end

  objects_array
end
