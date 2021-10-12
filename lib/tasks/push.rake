# frozen_string_literal: true

desc 'Push to Registry'
task :push do
  # check that the build system is available
  build_system = Docker.new
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  unless File.exist? '.build_id'
    puts 'Build and tag images first'.red
    exit(1)
  end
  build_id = File.read('.build_id')
  $images.each do |image|
    puts "Image: #{image.build_tag}"
    image.build_id = build_id
    image.registries.each do |registry|
      if registry['url'].contains_public_registry? && registry['org_name'].to_s.empty?
        puts "Not pushing to public registry \"#{registry['url']}\": set org_name for registry in metadata.yaml".red
        next
      end
      ron = image.registry_org_name(registry['url'], registry['org_name'])
      separator = ron.empty? ? '' : '/'
      sh "docker push #{ron}#{separator}#{image.name_tag}"
      image.tags.each do |tag|
        next if ron.empty?

        sh "docker push #{ron}#{separator}#{image.name_tag(tag)}"
      end
    end
  end
end
