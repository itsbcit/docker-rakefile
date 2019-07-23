class DockerImage
    attr_accessor :name, :tags, :variant, :version, :build_id, :registries,
                  :org_name, :maintainer, :vars
    attr_writer   :tags
    def initialize(
        name:,
        org_name:,
        build_id:   '',
        tags:       [],
        version:    '',
        variant:    '',
        registries: [],
        labels:     [],
        vars:       {}
    )
        @name       = name
        @org_name   = org_name
        @build_id   = build_id
        @tags       = tags
        @version    = version
        @variant    = variant
        @registries = registries
        @labels     = labels
        @vars       = vars
    end

    def dir
        if self.variant.empty? and self.version.empty?
            dir = './'
        else
            # format directory or './' based on version,variant
            dash = variant.empty? ? '' : '-'
            dir = "#{version}#{dash}#{variant}"
        end
        return dir
    end

    def tags=(tags)
        @tags = tags.uniq
    end
end
