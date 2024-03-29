# frozen_string_literal: true

desc 'Push to Registry'
task :push do
  # check that the build system is available
  build_system = Builder.new.runtime?
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  # keep track of image IDs we've already seen to we can help diagnose tagging conflicts
  seen_images = {}

  $images.each do |image|
    next unless image.push_image?

    puts "Image: #{image.build_name_tag}".pink

    # abort if image has not been built
    image_id = `#{build_system.name.downcase} image ls -q #{image.build_name_tag}`.strip
    if image_id.empty?
      puts "Image #{image.build_name_tag} has not been built.".red
      exit 1
    end

    puts "Image ID: #{image_id}"
    seen_images[image_id] = image.build_name_tag

    image.registries.each do |registry|
      if registry['url'].nil? or registry['url'] == 'docker.io'
        registry_url = ''
      else
        registry_url = registry['url']
      end

      sh "#{build_system.name.downcase} login #{registry['url']}"
      image.tags.each do |tag|
        ron          = image.parts_join('/', registry_url, registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
        ron_name_tag = image.parts_join(':', ron_name, tag)

        # abort if tag doesn't exist or tag is pointing to a different image
        image_tag_id = `#{build_system.name.downcase} image ls -q #{ron_name_tag}`.strip
        if image_tag_id.empty?
          puts "Tag not found: Image #{image.build_name_tag} has not been tagged with #{ron_name_tag}".red
          exit 1
        elsif (image_tag_id != image_id) && !(seen_images[image_tag_id].nil?)
          puts "#{ron_name_tag} tagged to #{seen_images[image_tag_id]} : tag conflict likely.".red
          exit 1
        end

        sh "#{build_system.name.downcase} push #{ron_name_tag}"
      end
    end
  end
end
