desc "Update Dockerfile templates"
task :template do
  puts "*** Rendering templates ***".green
  $images.each do |image|
    dir = image.dir.nil? ? '.' : image.dir
    FileUtils.mkdir_p dir unless image.dir.nil?

    image.files.each do |file|
      unless File.exist?(file)
        puts "WARNING: file not found: #{file}".red
        next
      end
      # if this is an ERB template...
      if file[-4..-1] == '.erb'
        #render the file without .erb extension
        render_template(file,"#{dir}/#{file[0..-5]}", binding)
      else
        FileUtils.cp(file,dir)
      end
    end
    puts "Rendering #{dir}/Dockerfile"
    #render_template("Dockerfile.erb", "#{dir}/Dockerfile", binding)
  end
end
