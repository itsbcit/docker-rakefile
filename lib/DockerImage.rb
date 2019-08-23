class DockerImage
    attr_reader   :suffixes
    attr_accessor :image_name, :variant, :version, :build_id,
                  :registries, :org_name, :maintainer, :labels, :vars, :files
    def initialize(
        image_name:,
        org_name:,
        build_id:   '',
        suffixes:   [''],
        version:    '',
        variant:    '',
        registries: [],
        labels:     {},
        vars:       {},
        files:      {}
    )
        @image_name = image_name
        @org_name   = org_name
        @build_id   = build_id
        @suffixes   = suffixes
        @version    = version
        @variant    = variant
        @registries = registries
        @labels     = labels.merge( { "build_id" => build_id } )
        @vars       = vars
        @files      = files
    end

    def base_tag()
        if self.version.empty?
            variant = self.variant
        else
            variant = self.variant.empty? ? '' : "-#{self.variant}"
        end

        prefix = "#{self.version}#{variant}".empty? ? '' : ':'

        return "#{prefix}#{self.version}#{variant}"
    end

    def build_tag()
        prefix="b"
        unless self.base_tag.empty?
            prefix = "-#{prefix}"
        end

        return "#{prefix}#{self.build_id}"
    end

    def dir
        if    self.variant.empty? and self.version.empty?
            dir = '.'
        elsif self.variant.empty?
            dir = self.version
        elsif self.version.empty?
            dir = self.variant
        else
            dir = "#{version}-#{variant}"
        end

        return dir
    end

    def suffixes=(suffixes)
        @suffixes += suffixes
        @suffixes  = @suffixes.uniq
    end

    def tags()
        tags     = []
        self.registries.each do |registry|
            tag   = "#{registry}/#{self.org_name}/#{self.image_name}:#{self.base_tag}"
            tags << tag
            tags << "#{tag}-latest"

            self.suffixes.each do |suffix|
                suffix = suffix.empty? ? '' : "-#{suffix}"
                tags << "#{tag}#{suffix}-latest"       unless suffix.include? 'latest'
                tags << "#{tag}#{suffix}"
            end
        end

        return tags.uniq
    end
end
