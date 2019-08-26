# frozen_string_literal: true

desc 'Build Docker images'
task :build do
  args = ARGV.length > 2 ? ARGV[2..-1].join(' ') : ''
  puts '*** Building images ***'.green
  File.unlink('.build_id') if File.exist?('.build_id')
  $images.each do |image|
    puts "Image: #{image.base_tag}".green
    File.open('.build_id', 'w') {|f| f.write(image.build_id) } unless File.exist?('.build_id')
    Dir.chdir("#{image.dir}") do
      sh "docker build -t #{image.base_tag} . #{args}"
    end
  end
end
