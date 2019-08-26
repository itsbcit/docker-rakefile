# frozen_string_literal: true

# Object classDockerImage
class DockerImage
  attr_reader   :suffixes
  attr_accessor :image_name, :variant, :version, :version_tags, :build_id,
                :registries, :org_name, :maintainer, :labels, :vars, :files
  def initialize(
    image_name:,
    org_name:,
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
  end

  def version_variant(version = self.version)
    variant = if version.empty?
                self.variant
              else
                self.variant.empty? ? '' : "-#{self.variant}"
              end

    "#{version}#{variant}"
  end

  def version_variant_build(version = self.version)
    vv = version_variant(version)
    prefix = vv.empty? ? '' : '-'

    "#{vv}#{prefix}b#{build_id}"
  end

  def version_variant_latest(version = self.version)
    vv = version_variant(version)
    prefix = vv.empty? ? '' : '-'

    "#{vv}#{prefix}latest"
  end

  def dir
    dir = if variant.empty? && version.empty?
            '.'
          elsif variant.empty?
            version
          elsif version.empty?
            variant
          else
            "#{version}-#{variant}"
          end

    dir
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
      suffix = version_variant.empty? ? suffix : "-#{suffix}"
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
