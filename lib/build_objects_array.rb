# frozen_string_literal: true

def build_objects_array(options = {})
  metadata         = options.fetch(:metadata, {})
  default_metadata = options.fetch(:default_metadata, {})

  def metadata.fetch(key, default)
    return default unless key?(key)

    return self[key] unless self[key].nil?

    # return an empty instance of the default if metadata value is nil
    default.class.new
  end

  base_labels    = metadata.fetch('base_labels',    default_metadata['base_labels'])
  base_tags      = metadata.fetch('base_tags',      default_metadata['base_tags'])
  base_vars      = metadata.fetch('base_vars',      default_metadata['base_vars'])
  build_image    = metadata.fetch('build',          default_metadata['build'])
  image_name     = metadata.fetch('image_name',     default_metadata['image_name'])
  labels         = metadata.fetch('labels',         default_metadata['labels'])
  maintainer     = metadata.fetch('maintainer',     default_metadata['maintainer'])
  push_image     = metadata.fetch('push',           default_metadata['push'])
  registries     = metadata.fetch('registries',     default_metadata['registries'])
  tag_image      = metadata.fetch('tag',            default_metadata['tag'])
  tags           = metadata.fetch('tags',           default_metadata['tags']) + base_tags
  template_files = metadata.fetch('template_files', default_metadata['template_files'])
  test_image     = metadata.fetch('test',           default_metadata['test'])
  variants       = metadata.fetch('variants',       default_metadata['variants'])
  vars           = metadata.fetch('vars',           default_metadata['vars'])
  versions       = metadata.fetch('versions',       default_metadata['versions'])
  test_command   = metadata.fetch('test_command',   default_metadata['test_command'])

  raise('Can\'t proceed with empty image name (hint: metadata.yaml >> image_name)') if image_name.nil? || image_name.empty?

  objects_array = []

  versions.each do |version, version_params|
    version_params         = version_params.nil? ? {} : version_params
    version_template_files = version_params.fetch('template_files', [])
    version_labels         = version_params.fetch('labels',         {})
    version_registries     = version_params.fetch('registries',     [])
    version_tags           = version_params.fetch('tags',           [])
    version_variants       = version_params.fetch('variants',       {})
    version_vars           = version_params.fetch('vars',           {})

    version_build_image    = version_params['build'].nil?          ? build_image  : version_params['build']
    test_command = version_params['test_command'].nil? ? test_command : version_params['test_command']
    version_push_image     = version_params['push'].nil?           ? push_image   : version_params['push']
    version_tag_image      = version_params['tag'].nil?            ? tag_image    : version_params['tag']
    version_test_image     = version_params['test'].nil?           ? test_image   : version_params['test']
    variants   = variants.deep_merge(version_variants)

    variants.each do |variant, variant_params|
      variant_params         = variant_params.nil? ? {} : variant_params
      variant_template_files = variant_params.fetch('template_files', [])
      variant_labels         = variant_params.fetch('labels',         {})
      variant_registries     = variant_params.fetch('registries',     [])
      variant_tags           = variant_params.fetch('tags',           [])
      variant_vars           = variant_params.fetch('vars',           {})
      variant_build_image    = variant_params['build'].nil?        ? version_build_image  : variant_params['build']
      variant_push_image     = variant_params['push'].nil?         ? version_push_image   : variant_params['push']
      variant_tag_image      = variant_params['tag'].nil?          ? version_tag_image    : variant_params['tag']
      variant_test_image     = variant_params['test'].nil?         ? version_test_image   : variant_params['test']

      merged_registries = merge_registries(registries, version_registries, variant_registries)
      merged_registries = merged_registries.empty? ? [{ url: '', org_name: '' }] : merged_registries

      test_command     = variant_params['test_command'].nil? ? test_command : variant_params['test_command']

      # make sure test_command isn't nil
      test_command = test_command.nil? ? '' : test_command

      objects_array << DockerImage.new(
        image_name: image_name,
        variant: variant,
        version: version,
        template_files: (template_files + version_template_files + variant_template_files).uniq,
        tags: (tags + version_tags + variant_tags).uniq,
        registries: merged_registries,
        labels: base_labels.deep_merge(labels).deep_merge(version_labels).deep_merge(variant_labels),
        maintainer: maintainer,
        push_image: variant_push_image,
        vars: base_vars.deep_merge(vars).deep_merge(version_vars).deep_merge(variant_vars)
        tag_image: variant_tag_image,
        test_image: variant_test_image,
      )
    end
  end

  objects_array
end
