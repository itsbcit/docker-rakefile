class DockerImage
    attr_writer   :tags
    attr_accessor :image_name, :tags, :variant, :version, :build_id, :registries,
                  :org_name, :maintainer, :labels, :vars, :files
    def initialize(
        image_name:,
        org_name:,
        build_id:   '',
        tags:       [],
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
        @tags       = tags
        @version    = version
        @variant    = variant
        @registries = registries
        @labels     = { "build_id" => build_id }.merge(labels)
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

    def tags=(tags)
        @tags = tags.uniq
    end
end
