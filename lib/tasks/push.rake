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
    exit 1
  end
  $images.each do |image|
    puts "Image: #{image.build_name_tag}".pink
    image.registries.each do |registry|
      if registry['url'].contains_public_registry? && registry['org_name'].to_s.empty?
        puts "Not pushing to public registry \"#{registry['url']}\": set org_name for registry in metadata.yaml".red
        next
      end
      ron = image.registry_org_name(registry['url'], registry['org_name'])
      separator = ron.empty? ? '' : '/'
      sh "docker push #{ron}#{separator}#{image.name_tag}"
      image.tags.each do |tag|
        ron          = image.parts_join('/', registry['url'], registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
        ron_name_tag = image.parts_join(':', ron_name, tag)
        sh "docker push #{ron_name_tag}"
      end
    end
  end
end
