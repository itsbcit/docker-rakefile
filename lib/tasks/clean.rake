# frozen_string_literal: true

desc 'Clean Docker/Podman build environment'
task :clean do
  # check that the build system is available
  build_system = Builder.new.runtime?
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  $images.each do |image|
    puts "Image: #{image.build_name_tag}".pink

    # delete image if it exists
    image_id = `#{build_system.name.downcase} image ls -q #{image.build_name_tag}`.strip
    sh "#{build_system.name.downcase} image rm -f #{image_id}" unless image_id.empty?

    # delete FROM image if it exists
    image_from = image.from
    unless image_from.nil?
      from_id = `#{build_system.name.downcase} image ls -q #{image_from}`.strip
      unless from_id.empty?
        puts "Deleting FROM image #{image_from}:".pink
        sh "#{build_system.name.downcase} image rm #{from_id}"
      end
    end

    image.registries.each do |registry|
      image.tags.each do |tag|
        ron          = image.parts_join('/', registry['url'], registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
        ron_name_tag = image.parts_join(':', ron_name, tag)

        # abort if tag doesn't exist or tag is pointing to a different image
        image_tag_id = `#{build_system.name.downcase} image ls -q #{ron_name_tag}`.strip
        sh "#{build_system.name.downcase} image rm #{ron_name_tag}" unless image_tag_id.empty?
      end
    end
  end

  puts 'Clearing Docker/podman build artifacts:'.pink
  sh "#{build_system.name.downcase} builder prune -f"
end
