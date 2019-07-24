class DockerImage
    attr_writer   :suffixes
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

    def dir
        if self.variant.empty? and self.version.empty?
            dir = nil
        else
            # format directory based on version,variant
            dash = variant.empty? ? '' : '-'
            dir = "#{version}#{dash}#{variant}"
        end
        return dir
    end

    def suffixes=(suffixes)
        @suffixes = suffixes.uniq
    end

    end
end
