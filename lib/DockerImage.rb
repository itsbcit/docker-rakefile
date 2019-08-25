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

  def base_tag(version = self.version)
    variant = if version.empty?
                self.variant
              else
                self.variant.empty? ? '' : "-#{self.variant}"
              end

    "#{version}#{variant}"
  end

  def build_tag(version = self.version)
    prefix = 'b'
    prefix = "-#{prefix}" unless base_tag(version).empty?

    "#{prefix}#{build_id}"
  end

  def latest(version = self.version)
    prefix = base_tag(version).empty? ? '' : '-'
    "#{prefix}latest"
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
    tags << base_tag
    tags << "#{base_tag}#{latest}"

    suffixes.each do |suffix|
      suffix = base_tag.empty? ? suffix : "-#{suffix}"
      tags << "#{base_tag}#{suffix}"
    end

    version_tags.each do |version_tag|
      tags << base_tag(version_tag).to_s
      tags << "#{base_tag(version_tag)}#{build_tag}"
      tags << "#{base_tag(version_tag)}#{latest}"
    end

    tags.uniq
  end
end
