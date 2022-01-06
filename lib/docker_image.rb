# frozen_string_literal: true

# Object class DockerImage
class DockerImage
  attr_reader :image_name, :template_files, :registries, :variant, :version, :maintainer, :test_command
  attr_accessor :build_id

  def initialize(
    image_name:,
    build_id:     0,
    test_command: '',
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
    @test_command       = test_command
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
    "local/#{parts_join(':', image_name, parts_join('-', version, variant, build_suffix))}"
  end

  alias build_tag build_name_tag

  def build_suffix
    "b#{@build_id}"
  end

  def dir
    version_variant = tag_join(version, variant)
    version_variant.empty? ? '.' : version_variant
  end

  def labels
    render_hash_values(@labels, binding)
  end

  def tags
    rendered_tags = render_array_values(@tags, binding)
    rendered_tags.reject! { |v| v.to_s.empty? }
    rendered_tags.uniq
  end

  # TODO: render ERB vars and labels
  def vars
    render_hash_values(@vars, binding)
  end

  def parts_join(glue, *parts)
    parts.reject! { |t| t.nil? || t.empty? }
    parts.join(glue).to_s
  end

  def tag_join(*parts)
    parts.reject! { |t| t.nil? || t.empty? }
    parts.join('-').to_s
  end

  def dockerfile
    "#{dir}/Dockerfile"
  end

  def from
    return unless File.exist?(dockerfile)

    # find the first FROM and return the Docker image reference
    File.readlines(dockerfile).each do |line|
      return line[5..-1] if line.start_with?('FROM ')
    end
  end
end
