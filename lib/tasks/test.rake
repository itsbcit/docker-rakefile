# frozen_string_literal: true

desc 'Test docker images'
task :test do
  # check that the build system is available
  build_system = Docker.new()
  unless build_system.running?
    puts "#{build_system.name} sanity check failed.".red
    exit 1
  end

  puts '*** Testing images ***'.green
  $images.each do |image|
    puts "Running tests on #{image.build_tag}"
    container = `docker run --rm -d #{image.build_tag} init-loop`.strip
    begin
      sh "/bin/sh -c \"echo hello from #{image.build_tag}\""
    ensure
      sh "docker kill #{container}"
    end
  end
end
