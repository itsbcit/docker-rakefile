# frozen_string_literal: true

desc 'Tag docker images'
task :tag do
  # check that the build system is available
  build_system = Docker.new
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  # TODO: check that the images have been built

  puts '*** Tagging images ***'.green
  $images.each do |image|
    puts "Image: #{image.build_name_tag}".pink
    image.registries.each do |registry|
      image.tags.each do |tag|
        ron          = image.parts_join('/', registry['url'], registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
        ron_name_tag = image.parts_join(':', ron_name, tag)
        sh "docker tag #{image.build_name_tag} #{ron_name_tag}"
      end
    end
  end
end
