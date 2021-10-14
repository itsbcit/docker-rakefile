# frozen_string_literal: true

# Object class DockerImage
class DockerImage
  attr_reader   :image_name, :build_id, :template_files, :registries,
                :variant, :version, :labels, :maintainer, :vars

  def initialize(
    image_name:,
    build_id:     0,
    variant:      '',
    version:      '',
    template_files: {},
    registries:   [],
    labels:       {},
    maintainer:   '',
    tags:         [],
    vars:         {}
  )
    @image_name         = image_name
    @build_id           = build_id
    @variant            = variant
    @version            = version
    @template_files     = template_files
    @registries         = registries
    @labels             = labels
    @maintainer         = maintainer
    @tags               = tags
    @vars               = vars

    # check for a forced build id in ENV
    @build_id = ENV['BUILD_ID'].nil? ? read_build_id : ENV['BUILD_ID']

    # create a new build id if zero
    new_build_id if @build_id.nil? || @build_id.zero?

    @tags << version_variant unless version_variant.empty?

    @tags << version_variant_build
    @tags = @tags.uniq
  end

  def new_build_id
    timestamp = Time.now.getutc.to_i
    write_build_id(timestamp)
    @build_id = timestamp
  end

  def read_build_id
    return 0 unless File.exist?('.build_id')

    File.read('.build_id').to_i
  end

  private :read_build_id

  def write_build_id(build_id)
    File.unlink('.build_id') if File.exist?('.build_id') && ENV['KEEP_BUILD'].nil?
    File.open('.build_id', 'w') { |f| f.write(build_id) } unless File.exist?('.build_id')
  end

  private :write_build_id

  def build_name_tag
    vvb = version_variant_build

    "local/#{image_name}:#{vvb}"
  end

  def build_suffix
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

  def version_variant_build(version = @version)
    vv = version_variant(version)
    separator = vv.to_s.empty? ? '' : '-'

    "#{vv}#{separator}#{build_suffix}"
  end

  def version_variant_latest(version = @version)
    vv = version_variant(version)
    separator = vv.to_s.empty? ? '' : '-'

    "#{vv}#{separator}latest"
  end

  def dir
    version_variant.to_s.empty? ? '.' : version_variant
  end

  def ron_name_tag(registry_url = '', registry_org_name = '', tag = name_tag)
    ron = registry_org_name(registry_url, registry_org_name)
    separator = ron.empty? ? '' : '/'
    "#{ron}#{separator}#{tag}"
  end

  def tags
    rendered_tags = []
    @tags.each do |tag|
      rendered_tags << render_inline_template(tag, binding)
    end
    rendered_tags
  end

  def tag_concat(tag_parts)
    tag_parts.reject! { |t| t.nil? || t.empty? }
    tag_parts.join('-')
  end
end
