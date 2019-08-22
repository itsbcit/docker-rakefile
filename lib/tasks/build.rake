desc "Build Docker images"
task :build do
  puts "*** Building images ***".green
  $images.each do |image|
    puts "#{image.image_name}: \"#{image.dir}\""
    # Dir.chdir(image.dir) do
    #   puts "docker build -t #{registry}/#{org_name}/#{image}:#{tag} . --no-cache --pull".red
    # end
  end
end
