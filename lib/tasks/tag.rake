# frozen_string_literal: true

desc 'Tag docker images'
task :tag do
  # check that the build system is available
  build_system = Docker.new
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  # keep track of image IDs we've seen and make sure we're not creating conflicting tags
  seen_images = {}

  puts '*** Tagging images ***'.green
  $images.each do |image|
    next unless image.tag_image?

    puts "Image: #{image.build_name_tag}".pink

    # abort if image has not been built
    image_id = `docker image ls -q #{image.build_name_tag}`.strip
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
        registry_url = registry_url
      end

      image.tags.each do |tag|
        ron          = image.parts_join('/', registry_url, registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
        ron_name_tag = image.parts_join(':', ron_name, tag)

        # abort if we're trying to overwite a tag already assigned to a different image in this run
        # try to look up an existing tag by the same name
        image_tag_id = `docker image ls -q #{ron_name_tag}`.strip
        # if the image id matches one we've seen before, and it's not adding another tag to the same image, abort
        if !seen_images[image_tag_id].nil? && (image_tag_id != image_id)
          puts "#{ron_name_tag} already tagged to #{seen_images[image_tag_id]}\nTag conclict! Check tags in metadata.yaml or \"rake clean\".".red
          exit 1
        end

        sh "docker tag #{image.build_name_tag} #{ron_name_tag}"
      end
    end
  end
end
