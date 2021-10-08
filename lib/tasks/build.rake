# frozen_string_literal: true

desc 'Build Docker images'
task :build do
  # check that the build system is available
  build_system = Docker.new()
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  puts '*** Building images ***'.green
  $images.each do |image|
    puts "Image: #{image.build_tag} (build_id: #{image.build_id})".green
    sh "docker build -f #{image.dir}/Dockerfile -t #{image.build_tag} ."
    # sh "docker build -f #{image.dir}/Dockerfile -t #{image.build_tag} . --no-cache --pull"
  end
end
