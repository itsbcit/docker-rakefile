# frozen_string_literal: true

desc 'Build Docker/podman images'
task :build do
  # check that the build system is available
  build_system = Builder.new.runtime?
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  puts '*** Building images ***'.green
  $images.each do |image|
    next unless image.build_image?
    
    build_tag = image.build_name_tag
    puts "Image: #{build_tag}".pink
    sh "#{build_system.name.downcase}  build -f #{image.dir}/Dockerfile -t #{build_tag} ."
    image_id = `#{build_system.name.downcase} image ls -q #{build_tag}`.strip
    puts "Image ID: #{image_id}"
  end
end
