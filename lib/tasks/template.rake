desc "Update Dockerfile templates"
task :template do
  puts "*** Rendering templates ***".green
    if image.include? '-supervisord'
      FileUtils.cp 'supervisor.conf',"#{dir}/supervisor.conf"
  $images.each do |image|
    FileUtils.mkdir_p dir unless image.dir.nil?
    end
    puts "Rendering #{dir}/Dockerfile"
    #render_template("Dockerfile.erb", "#{dir}/Dockerfile", binding)
  end
end
