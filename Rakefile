# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'tempfile'
require 'yaml'
require 'open-uri'

Dir.glob('lib/*.rb').each { |l| load l } if Dir.exist?('lib')
Dir.glob('lib/*.rb').each { |l| load l } if Dir.exist?('local')

puts("WARNING: metadata.yaml not found.") unless File.exist?('metadata.yaml')

if File.exist?('metadata.yaml')
  $metadata = YAML.safe_load(File.read('metadata.yaml'))
  $images = build_objects_array(
    metadata: $metadata,
    build_id: build_timestamp
  )
end

desc 'Install Rakefile support files'
task :install do
  open('https://github.com/itsbcit/docker-template/releases/latest/download/lib.zip') do |archive|
    FileUtils.remove_entry('lib') if File.exist?('lib')
    tempfile = Tempfile.new(['lib', '.zip'])
    File.open(tempfile.path, 'wb') do |f|
      f.write(archive.read)
    end
    system('unzip', tempfile.path)
    tempfile.unlink
  end
end

Dir.glob('lib/tasks/*.rake').each { |r| load r } if Dir.exist?('lib/tasks')
Dir.glob('lib/tasks/*.rake').each { |r| load r } if Dir.exist?('local/tasks')
