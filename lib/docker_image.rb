# frozen_string_literal: true

# Object class DockerImage
class DockerImage
  attr_reader   :image_name, :suffixes, :build_name_tag, :template_files, :registries,
                :variant, :version, :labels, :maintainer, :vars

  def initialize(
    image_name:   ,
    build_id:     0,
    variant:      '',
    version:      '',
    template_files: {},
    suffixes:     [''],
    registries:   [],
    labels:       {},
    maintainer:   '',
    vars:         {}
  )
    @image_name         = image_name
    @build_id           = build_id
    @variant            = variant
    @version            = version
    @template_files     = template_files
    @suffixes           = suffixes
    @registries         = registries
    @labels             = labels
    @maintainer         = maintainer
    @vars               = vars

    @labels['build_id'] = build_id
  end

  def build_name_tag()
    vvb = version_variant_build()

    "local/#{image_name}:#{vvb}"
  end

  def build_suffix()
    "b#{@build_id}"
  end

  def registry_name_tag(registry = '', org_name = '')
    ron = registry_org_name(registry, org_name)
    separator = ron.to_s.empty? ? '' : '/'

    "#{ron}#{separator}#{name_tag}"
  end

  def registry_org_name(registry = '', org_name = self.org_name)
    separator = if registry.to_s.empty?
                  ''
                else
                  org_name.to_s.empty? ? '' : '/'
                end

    "#{registry}#{separator}#{org_name}"
  end

  def version_variant(version = self.version)
    separator = if version.to_s.empty?
                  ''
                else
                  variant.to_s.empty? ? '' : '-'
                end

    "#{version}#{separator}#{variant}"
  end

  def name_tag(tag = version_variant())
    separator = tag.to_s.empty? ? '' : ':'

    "#{image_name}#{separator}#{tag}"
  end

  def version_variant_build(version = self.version)
    vv = version_variant(version)
    prefix = vv.to_s.empty? ? '' : '-'

    "#{vv}#{prefix}#{build_suffix}"
  end

  def version_variant_latest(version = self.version)
    vv = version_variant(version)
    prefix = vv.to_s.empty? ? '' : '-'

    "#{vv}#{prefix}latest"
  end

  def dir
    version_variant.to_s.empty? ? '.' : version_variant
  end

  def suffixes=(suffixes)
    @suffixes += suffixes
    @suffixes  = @suffixes.uniq
  end

  # TODO: this should calculate all image tags. Bring that here out of the tag and push tasks
  def tags
    tags = []
    tags << version_variant_build
    tags << version_variant_latest

    suffixes.each do |suffix|
      suffix = version_variant.to_s.empty? ? suffix : "-#{suffix}"
      tags << "#{version_variant}#{suffix}"
    end

    tags.uniq
  end
end
