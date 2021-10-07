# frozen_string_literal: true

# Object class Docker
class Docker
  attr_reader :name

  def initialize()
    @name = "Docker"
  end

  def running?
    system('docker ps -q') or return false
    return true
  end
end
