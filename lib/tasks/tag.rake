desc "Tag docker images"
task :tag do
  # TODO: each registry should register an org name
  puts "*** Tagging images ***".green
  $images.each do |image|
    puts "Image: #{image.image_name}#{image.base_tag(image.version)}"
    image.registries.each do |registry|
      image.tags.each do |tag|
        puts tag.yellow
        puts "docker tag #{registry}/#{image.org_name}/#{image.image_name}#{image.base_tag(image.version)} #{registry}/#{image.org_name}/#{image.image_name}#{tag}".red
      end
    end
  end
end
