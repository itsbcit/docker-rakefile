# frozen_string_literal: true

# Object class Builder
class Builder
    attr_reader :name
  
    # docker first, then podman
    def initialize
      @name = 'Builder'
    end

    def runtime?
        begin
            docker = Docker.new
            podman = Podman.new
        rescue
        end
        if docker.running?
            return docker
        elsif podman.running?
            return podman
        end
    end
end
  