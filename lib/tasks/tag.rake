# frozen_string_literal: true

desc 'Tag docker images'
task :tag do
  # check that the build system is available
  build_system = Docker.new()
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  puts '*** Tagging images ***'.green
  $images.each do |image|
    puts "Image: #{image.build_name_tag}"
    image.registries.each do |registry|
      unless registry['url'].respond_to?(:contains_public_registry?)
        puts 'Skipping registry with invalid url: check metadata.yaml'.red
        next
      end
      if registry['url'].contains_public_registry? && registry['org_name'].to_s.empty?
        puts "Not tagging to public registry \"#{registry['url']}\": set org_name #{registry['org_name']} for registry in metadata.yaml".red
      end
      ron = image.registry_org_name(registry['url'], registry['org_name'])
      separator = ron.empty? ? '' : '/'
      sh "docker tag #{image.build_name_tag} #{ron}#{separator}#{image.name_tag}"
      image.tags.each do |tag|
        sh "docker tag #{image.build_name_tag} #{ron}#{separator}#{image.name_tag(tag)}"
      end
    end
  end
end
