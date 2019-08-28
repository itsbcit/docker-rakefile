# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'yaml'

Dir.glob('lib/*.rb').each { |l| load l } if Dir.exist?('lib')
Dir.glob('lib/*.rb').each { |l| load l } if Dir.exist?('local')

abort("ERROR: metadata.yaml not found.") unless File.exist?('metadata.yaml')

$images = build_objects_array(
  metadata: YAML.safe_load(File.read('metadata.yaml')),
  build_id: build_timestamp
)

Dir.glob('lib/tasks/*.rake').each { |r| load r } if Dir.exist?('lib/tasks')
Dir.glob('lib/tasks/*.rake').each { |r| load r } if Dir.exist?('local/tasks')
