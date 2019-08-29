# frozen_string_literal: true

desc 'Test docker images'
task :test do
  puts '*** Testing images ***'.green
  $images.each do |image|
    puts "Running tests on #{image.base_tag}"
    sh "docker run --rm #{image.base_tag} /bin/sh -c \"echo hello from #{image.base_tag}\""
  end
end
