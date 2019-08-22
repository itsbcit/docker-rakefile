desc "Update Dockerfile templates"
task :template do
  puts "*** Rendering templates ***".green
  $images.each do |image|
    dir = image.dir.nil? ? '.' : image.dir
    FileUtils.mkdir_p dir unless image.dir.nil?

    image.files.each do |file|
      # TODO: if the last four characters are '.erb'...
      if file.include? '.erb'
        #render the file without .erb extension
      else
        FileUtils.cp(file,dir)
      end
    end
    puts "Rendering #{dir}/Dockerfile"
    #render_template("Dockerfile.erb", "#{dir}/Dockerfile", binding)
  end
end
