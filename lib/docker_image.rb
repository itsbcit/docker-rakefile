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
    "local/#{parts_join('-', image_name, version, variant, build_suffix)}"
  end

  def build_suffix
    "b#{@build_id}"
  end

  def dir
    version_variant.to_s.empty? ? '.' : version_variant
  end

  def tags
    rendered_tags = []
    @tags.each do |tag|
      rendered_tag = render_inline_template(tag, binding)
      next if rendered_tag.to_s == ''

      rendered_tags << rendered_tag
    end
    rendered_tags.uniq
  end

  def parts_join(glue, *parts)
    parts.reject! { |t| t.nil? || t.empty? }
    parts.join(glue).to_s
  end

  def tag_join(*parts)
    parts.reject! { |t| t.nil? || t.empty? }
    parts.join('-').to_s
  end
end
