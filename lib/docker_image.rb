# frozen_string_literal: true

# Object class DockerImage
class DockerImage
                :variant, :version, :labels, :maintainer, :vars
  attr_reader   :image_name, :build_id, :build_name_tag, :template_files, :registries,

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

    # check for a forced build id in ENV
    if ENV['BUILD_ID'] != nil
      @build_id = ENV['BUILD_ID']
    # set build_id
    else
      @build_id = read_build_id()
    end

    # create a new build id if zero
    if @build_id.nil? || @build_id == 0
      new_build_id()
    end
  end

  def new_build_id
    timestamp = Time.now.getutc.to_i
    write_build_id(timestamp)
    @build_id = timestamp
  end

  def read_build_id()
    return 0 unless File.exist?('.build_id')
    File.read('.build_id').to_i
  end

  private :read_build_id

  def write_build_id(build_id)
    File.unlink('.build_id') if File.exist?('.build_id') && ENV['KEEP_BUILD'].nil?
    File.open('.build_id', 'w') { |f| f.write(build_id) } unless File.exist?('.build_id')
  end

  private :write_build_id

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

  # TODO: are suffixes really needed? We do need a way to declare whole tags. Maybe extra_tags?
  #       Put tags back? There needs to be these generated standard tags, and also whole tags.
  def tags
    tags = []
    tags << version_variant
    tags << version_variant_build

    # suffixes.each do |suffix|
    #   suffix = version_variant.to_s.empty? ? suffix : "-#{suffix}"
    #   tags << "#{version_variant}#{suffix}"
    # end

    tags.uniq
  end

  def suffixes
    (@suffixes << build_suffix).uniq
  def ron_name_tag(registry_url = '', registry_org_name = '')
    ron = registry_org_name(registry_url, registry_org_name)
    separator = ron.empty? ? '' : '/'
    "#{ron}#{separator}#{@name_tag}"
  end
end
