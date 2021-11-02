# frozen_string_literal: true

def build_objects_array(options = {})
  metadata         = options.fetch(:metadata, {})
  default_metadata = options.fetch(:default_metadata, {})

  base_labels    = metadata.key?('base_labels') ? metadata['base_labels'] : default_metadata['base_labels']

  base_labels    = metadata.fetch('base_labels',    default_metadata['base_labels'])
  base_tags      = metadata.fetch('base_tags',      default_metadata['base_tags'])
  base_vars      = metadata.fetch('base_vars',      default_metadata['base_vars'])
  image_name     = metadata.fetch('image_name',     default_metadata['image_name'])
  labels         = metadata.fetch('labels',         default_metadata['labels'])
  maintainer     = metadata.fetch('maintainer',     default_metadata['maintainer'])
  registries     = metadata.fetch('registries',     default_metadata['registries'])
  tags           = metadata.fetch('tags',           default_metadata['tags']) + base_tags
  template_files = metadata.fetch('template_files', default_metadata['template_files'])
  variants       = metadata.fetch('variants',       default_metadata['variants'])
  vars           = metadata.fetch('vars',           default_metadata['vars'])
  versions       = metadata.fetch('versions',       default_metadata['versions'])

  raise('Can\'t proceed with empty image name (hint: metadata.yaml >> image_name)') if image_name.nil? || image_name.empty?

  versions.each do |version, version_params|
    version_params         = version_params.nil? ? {} : version_params
    version_template_files = version_params.fetch('template_files', [])
    version_labels         = version_params.fetch('labels',         {})
    version_registries     = version_params.fetch('registries',     [])
    version_tags           = version_params.fetch('tags',           [])
    version_variants       = version_params.fetch('variants',       {})
    version_vars           = version_params.fetch('vars',           {})

    maintainer = version_params['maintainer'].nil? ? maintainer : version_params['maintainer'].nil?
    variants   = variants.deep_merge(version_variants)

    variants.each do |variant, variant_params|
      variant_params         = variant_params.nil? ? {} : variant_params
      variant_template_files = variant_params.fetch('template_files', [])
      variant_labels         = variant_params.fetch('labels',         {})
      variant_registries     = variant_params.fetch('registries',     [])
      variant_tags           = variant_params.fetch('tags',           [])
      variant_vars           = variant_params.fetch('vars',           {})

      merged_registries = merge_registries(registries, version_registries, variant_registries)
      merged_registries = merged_registries.empty? ? [{ url: '', org_name: '' }] : merged_registries

      objects_array = []
      objects_array << DockerImage.new(
        image_name: image_name,
        variant: variant,
        version: version,
        template_files: (template_files + version_template_files + variant_template_files).uniq,
        tags: (tags + version_tags + variant_tags).uniq,
        registries: merged_registries,
        labels: base_labels.deep_merge(labels).deep_merge(version_labels).deep_merge(variant_labels),
        maintainer: maintainer,
        vars: base_vars.deep_merge(vars).deep_merge(version_vars).deep_merge(variant_vars)
      )
    end
  end

  objects_array
end
