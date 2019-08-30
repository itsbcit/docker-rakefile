# frozen_string_literal: true

desc 'Build Docker images'
task :build do
  puts '*** Building images ***'.green
  File.unlink('.build_id') if File.exist?('.build_id') && ENV['KEEP_BUILD'].nil?
  $images.each do |image|
    puts "Image: #{image.base_tag} (build_id: #{image.build_id})".green
    File.open('.build_id', 'w') { |f| f.write(image.build_id) } unless File.exist?('.build_id')
    Dir.chdir(image.dir) do
      sh "docker build -t #{image.base_tag} . --no-cache --pull"
    end
  end
end
