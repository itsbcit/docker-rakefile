# frozen_string_literal: true

# Object class Podman
class Podman
    attr_reader :name
  
    def initialize
      @name = 'Podman'
    end
  
    def running?
      system('podman ps -q') or return false
      true
    end
  end
  