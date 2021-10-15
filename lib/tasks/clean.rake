# frozen_string_literal: true

desc 'Clean Docker build environment'
task :clean do
  # check that the build system is available
  build_system = Docker.new
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  $images.each do |image|
    puts "Image: #{image.build_name_tag}".pink

    # delete image if it exists
    image_id = `docker image ls -q #{image.build_name_tag}`
    sh "docker image rm -f #{image_id}" unless image_id.empty?

    # delete FROM image if it exists
    image_from = image.from
    unless image_from.nil?
      from_id = `docker image ls -q #{image_from}`
      unless from_id.empty?
        puts "Deleting FROM image #{image_from}:".pink
        sh "docker image rm #{image_id}"
      end
    end

    image.registries.each do |registry|
      image.tags.each do |tag|
        ron          = image.parts_join('/', registry['url'], registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
        ron_name_tag = image.parts_join(':', ron_name, tag)

        # abort if tag doesn't exist or tag is pointing to a different image
        image_tag_id = `docker image ls -q #{ron_name_tag}`
        sh "docker image rm #{ron_name_tag}" unless image_tag_id.empty?
      end
    end
  end

  puts 'Clearing Docker build artifacts:'.pink
  sh 'docker builder prune -f'
end
