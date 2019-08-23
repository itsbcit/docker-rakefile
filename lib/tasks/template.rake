desc "Update Dockerfile templates"
task :template do
  puts "*** Rendering templates ***".green
  $images.each do |image|
    puts "Image: #{image.image_name}:#{image.base_tag}"
    dir = image.dir.nil? ? '.' : image.dir
    FileUtils.mkdir_p dir unless image.dir.nil?

    image.files.each do |file|
      unless File.exist?(file)
        puts "WARNING: file not found: #{file}".red
        next
      end
      # if this is an ERB template...
      if (file.size > 4) and (file[-4..-1] == '.erb')
        #render the file without .erb extension
        outfile = file[0..-5]
        puts "\tRendering #{dir}/#{outfile}"
        render_template(file,"#{dir}/#{outfile}", binding)
      else
        puts "\tCopying #{dir}/#{file}"
        FileUtils.cp(file,dir)
      end
    end
    puts "\tRendering #{dir}/Dockerfile"
    render_template("Dockerfile.erb", "#{dir}/Dockerfile", binding)
  end
end
