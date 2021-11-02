# frozen_string_literal: true

desc 'Update Dockerfile templates'
task :template do
  # dummy DockerImage for managing build_id
  dummy = DockerImage.new(image_name: 'dummy')
  dummy.new_build_id if ENV['KEEP_BUILD'].nil?
  build_id = dummy.build_id
  dummy = nil
  puts "*** New Build ID: #{build_id} ***".green
  puts '*** Rendering templates ***'.green

  $images.each do |image|
    image.build_id = build_id
    puts "Image: #{image.build_name_tag}"
    dir = image.dir
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

    # TODO: implement per-"version-variant" rendered files
    image.template_files.each do |file|
      unless File.exist?(file)
        puts "WARNING: file not found: #{file}".red
        next
      end
      # if this is an ERB template...
      # TODO: rewrite this using ruby File methods basename, extname, etc
      if (file.size > 4) && (file[-4..-1] == '.erb')
        # render the file without .erb extension
        outfile = file[0..-5]
        puts "\tRendering #{dir}/#{outfile}"
        render_template(file, "#{dir}/#{outfile}", binding)
      else
        next if dir == '.'

        # Deprecation warning
        puts "\tWARNING: #{file} is not a templated file: not copying!".yellow
      end
    end

    if File.exist?("#{dir}/Dockerfile.erb")
      puts "\tRendering #{dir}/Dockerfile from #{dir}/Dockerfile.erb"
      render_template("#{dir}/Dockerfile.erb", "#{dir}/Dockerfile", binding)
    elsif image.variant != '' && File.exist?("#{image.variant}/Dockerfile.erb")
      puts "\tRendering #{dir}/Dockerfile from #{image.variant}/Dockerfile.erb"
      render_template("#{image.variant}/Dockerfile.erb", "#{dir}/Dockerfile", binding)
    elsif image.version != '' && File.exist?("#{image.version}/Dockerfile.erb")
      puts "\tRendering #{dir}/Dockerfile from #{image.version}/Dockerfile.erb"
      render_template("#{image.version}/Dockerfile.erb", "#{dir}/Dockerfile", binding)
    elsif File.exist?('Dockerfile.erb')
      puts "\tRendering #{dir}/Dockerfile from Dockerfile.erb"
      render_template('Dockerfile.erb', "#{dir}/Dockerfile", binding)
    else
      puts "\tNo Dockerfile template to render".yellow
    end
  end
end
