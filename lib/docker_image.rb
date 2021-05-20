# frozen_string_literal: true

# Object classDockerImage
class DockerImage
  attr_reader   :suffixes
  attr_accessor :image_name, :variant, :version, :version_tags, :build_id,
                :registries, :org_name, :maintainer, :labels, :vars, :files
  def initialize(
    image_name:,
    org_name:     '',
    build_id:     '',
    suffixes:     [''],
    version:      '',
    version_tags: [],
    variant:      '',
    registries:   [],
    labels:       {},
    vars:         {},
    files:        {}
  )
    @image_name   = image_name
    @org_name     = org_name
    @build_id     = build_id
    @suffixes     = suffixes
    @version      = version
    @version_tags = version_tags
    @variant      = variant
    @registries   = registries
    @labels       = labels.merge('build_id' => build_id)
    @vars         = vars
    @files        = files

    @registries += [{ 'url' => '', 'org_name' => org_name }] unless org_name.to_s.empty?
  end

  def base_tag(registry = '', org_name = self.org_name)
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

    "#{vv}#{prefix}b#{build_id}"
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

  def tags
    tags = []
    tags << version_variant_build
    tags << version_variant_latest

    suffixes.each do |suffix|
      suffix = version_variant.to_s.empty? ? suffix : "-#{suffix}"
      tags << "#{version_variant}#{suffix}"
    end

    version_tags.each do |version_tag|
      tags << version_variant(version_tag)
      tags << version_variant_build(version_tag)
      tags << version_variant_latest(version_tag)
    end

    tags.uniq
  end
end
