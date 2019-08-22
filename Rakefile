require 'erb'
require 'fileutils'
require 'yaml'

Dir.glob('lib/*.rb').each { |l| load l } if Dir.exist?('lib')

$images    = build_objects_array(
              metadata: YAML.load(File.read('metadata.yaml')),
              build_id: build_timestamp()
             ) if File.exist?('metadata.yaml')

Dir.glob('lib/tasks/*.rake').each { |r| load r } if Dir.exist?('lib/tasks')

# initalize the project
