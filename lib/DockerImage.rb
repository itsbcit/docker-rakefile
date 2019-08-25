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
        @image_name = image_name
        @org_name   = org_name
        @build_id   = build_id
        @suffixes   = suffixes
        @version    = version
        @version_tags = version_tags
        @variant    = variant
        @registries = registries
        @labels     = labels.merge( { "build_id" => build_id } )
        @vars       = vars
        @files      = files
    end

    def base_tag(version=self.version)
        if version.empty?
            variant = self.variant
        else
            variant = self.variant.empty? ? '' : "-#{self.variant}"
        end

        prefix = "#{version}#{variant}".empty? ? '' : ':'

        return "#{prefix}#{version}#{variant}"
    end

    def build_tag(version=self.version)
        prefix="b"
        unless self.base_tag(version).empty?
            prefix = "-#{prefix}"
        end

        return "#{prefix}#{self.build_id}"
    end

    def latest(version=self.version)
        prefix = self.base_tag(version).empty? ? '' : '-'
        return "#{prefix}latest"
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
        tags << "#{self.base_tag}#{self.build_tag}"
        tags << "#{self.base_tag}#{self.latest}"

        self.suffixes.each do |suffix|
            suffix = self.base_tag.empty? ? suffix : "-#{suffix}"
            tags << "#{self.base_tag}#{suffix}"
        end

        self.version_tags.each do |version_tag|
            tags << "#{self.base_tag(version_tag)}"
            tags << "#{self.base_tag(version_tag)}#{self.build_tag(self.version)}"
            tags << "#{self.base_tag(version_tag)}#{self.latest(self.version)}"
        end

        return tags.uniq
    end
end
