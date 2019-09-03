# frozen_string_literal: true

desc 'Test docker images'
task :test do
  puts '*** Testing images ***'.green
  $images.each do |image|
    puts "Running tests on #{image.base_tag}"
    container = `docker run --rm -d #{image.base_tag} init-loop`.strip
    begin
      sh "/bin/sh -c \"echo hello from #{image.base_tag}\""
    ensure
      sh "docker kill #{container}"
    end
  end
end
