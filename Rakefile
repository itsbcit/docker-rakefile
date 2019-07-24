require 'erb'
require 'fileutils'
require 'yaml'

Dir.glob('lib/*.rb').each { |l| load l }

images    = build_objects_array(
              metadata: YAML.load(File.read('metadata.yaml')),
              build_id: build_timestamp()
            )

maintainer        = metadata['maintainers'].join(', ')
registry          = metadata['registry']
org_name          = metadata['org_name']
image_name        = metadata['image_name']
tini_version      = metadata['tini_version']
de_version        = metadata['de_version']
dockerize_version = metadata['dockerize_version']
version           = metadata['version']
versions          = metadata['versions']
variants          = metadata['variants']

if ENV['timestamp'].nil?
  timestamp = Time.now.getutc.to_i
else
  timestamp = ENV['timestamp']
end

# tag with build timestamp
tags = [
  "b#{timestamp}"
]

tags += metadata['tags']

images = []
versions.each do |version|
  variants.each do |variant|
    varsep = '-' unless variant.empty?
    images << "#{version}#{varsep}#{variant}"
  end
end

unless ENV['registry'].nil?
  registry = ENV['registry']
end

Dir.glob('lib/tasks/*.rake').each { |r| load r }
