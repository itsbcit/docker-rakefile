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
        version  = self.version.empty? ? '' : "-#{self.version}"
        variant  = self.variant.empty? ? '' : "-#{self.variant}"
        return "#{self.image_name}#{version}#{variant}"
    end

    def dir
        if    self.variant.empty? and self.version.empty?
            dir = nil
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
            tag   = "#{registry}/#{self.org_name}/#{self.base_tag}"
            tags << tag
            tags << "#{tag}-b#{build_id}"
            tags << "#{tag}-latest"

            self.suffixes.each do |suffix|
                suffix = suffix.empty? ? '' : "-#{suffix}"
                tags << "#{tag}#{suffix}-b#{build_id}" unless suffix.include? 'latest'
                tags << "#{tag}#{suffix}-latest"       unless suffix.include? 'latest'
                tags << "#{tag}#{suffix}"
            end
        end

        return tags.uniq
    end
end
