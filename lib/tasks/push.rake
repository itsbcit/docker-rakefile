# frozen_string_literal: true

desc 'Push to Registry'
task :push do
  # check that the build system is available
  build_system = Docker.new
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  $images.each do |image|
    puts "Image: #{image.build_name_tag}".pink

    # abort if image has not been built
    image_id = `docker image ls -q #{image.build_name_tag}`
    if image_id.empty?
      puts "Image #{image.build_name_tag} has not been built.".red
      exit 1
    else
      puts "Image ID: #{image_id}"
    end

    image.registries.each do |registry|
      sh "docker login #{registry['url']}" unless registry['url'].to_s.empty?
      image.tags.each do |tag|
        ron          = image.parts_join('/', registry['url'], registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
        ron_name_tag = image.parts_join(':', ron_name, tag)

        # abort if tag doesn't exist or tag is pointing to a different image
        image_tag_id = `docker image ls -q #{ron_name_tag}`
        if image_tag_id.empty? || (image_tag_id != image_id)
          puts "Image #{image.build_name_tag} has not been tagged with #{ron_name_tag}.".red
          exit 1
        end

        sh "docker push #{ron_name_tag}"
      end
    end
  end
end
