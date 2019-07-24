desc "Build Docker images"
task :build do
  puts "*** Building images ***".green
  images.each do |image|
    Dir.chdir(image) do
      sh "echo docker build -t #{registry}/#{org_name}/#{image}:#{tag} . --no-cache --pull"
    end
  end
end
