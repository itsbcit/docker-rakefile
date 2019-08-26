# frozen_string_literal: true

desc 'Tag docker images'
task :tag do
  # TODO: each registry should register an org name
  puts '*** Tagging images ***'.green
  $images.each do |image|
    puts "Image: #{image.image_name}:#{image.version_variant}"
    image.registries.each do |registry|
      image.tags.each do |tag|
        puts tag.yellow
        puts "docker tag #{registry}/#{image.org_name}/#{image.image_name}:#{image.version_variant_build} #{registry}/#{image.org_name}/#{image.image_name}:#{tag}".red
      end
    end
  end
end
