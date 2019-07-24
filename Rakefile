require 'erb'
require 'fileutils'
require 'yaml'

Dir.glob('lib/*.rb').each { |l| load l }

metadata = YAML.load(File.read('metadata.yaml'))

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

desc "Template, build, tag, push"
task :default do
  Rake::Task[:Dockerfile].invoke
  Rake::Task[:build].invoke
  Rake::Task[:tag].invoke
  Rake::Task[:test].invoke
end

desc "Update Dockerfile templates"
task :Dockerfile do
  puts "*** Rendering templates ***".green
  images.each do |image|
    FileUtils.mkdir_p dir
    if image.include? '-supervisord'
      FileUtils.cp 'supervisor.conf',"#{dir}/supervisor.conf"
    end
    puts "Rendering #{dir}/Dockerfile"
    render_template("Dockerfile.erb", "#{dir}/Dockerfile", binding)
  end
end

desc "Build Docker images"
task :build do
  puts "*** Building images ***".green
  images.each do |image|
    Dir.chdir(image) do
      sh "echo docker build -t #{registry}/#{org_name}/#{image}:#{tag} . --no-cache --pull"
    end
  end
end

desc "Tag docker images"
task :tag do
  tags.each do |tag|
  end
end

desc "Test docker images"
task :test do
  puts "*** Tagging images ***".green
  tags.each do |tag|
    Dir.chdir(tag) do
      puts "Running tests on #{org_name}/#{image_name}:#{tag}"
      sh "echo docker run --rm #{registry}/#{org_name}/#{image_name}:#{tag} /bin/sh -c \"echo hello from #{org_name}/#{image_name}:#{tag}\""
    end
  end
end

desc "Push to Registry"
task :push do
  images.each do |image|
    puts "*** Pushing #{org_name}/#{image} to #{registry}".green
    puts "docker push #{registry}/#{org_name}/#{image}".pink
    tags.each do |tag|
      puts "*** Pushing #{org_name}/#{image}:#{tag} to #{registry}".green
      puts "docker push #{registry}/#{org_name}/#{image}-#{tag}".pink
    end
  end
end

desc "Update Rakefile"
task :update do
  # TODO: download latest rakefile from Github
end
