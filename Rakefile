require 'erb'
require 'fileutils'
require 'yaml'

Dir.glob('lib/*.rb').each { |l| load l }

images    = build_objects_array(
              metadata: YAML.load(File.read('metadata.yaml')),
              build_id: build_timestamp()
            )

Dir.glob('lib/tasks/*.rake').each { |r| load r }
