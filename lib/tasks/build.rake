desc "Build Docker images"
task :build do
  puts "*** Building images ***".green
  $images.each do |image|
    image.registries.each do |registry|
      puts "Image: #{image.image_name}#{image.base_tag}"
      Dir.chdir(image.dir) do
        sh "docker build -t #{registry}/#{image.org_name}/#{image.image_name}#{image.base_tag} . --no-cache --pull"
      end
    end
  end
end
