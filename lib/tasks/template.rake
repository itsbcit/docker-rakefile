desc "Update Dockerfile templates"
task :template do
  puts "*** Rendering templates ***".green
  images.each do |image|
    FileUtils.mkdir_p dir
    if image.include? '-supervisord'
      FileUtils.cp 'supervisor.conf',"#{dir}/supervisor.conf"
    end
    puts "Rendering #{dir}/Dockerfile"
    #render_template("Dockerfile.erb", "#{dir}/Dockerfile", binding)
  end
end
