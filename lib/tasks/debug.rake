# frozen_string_literal: true

desc 'Debug rakefile objects'
task :debug do
  puts '*** Debug image objects ***'.green
  $images.each do |image|
    #next unless image.variant == ""
    puts "Image: #{image.build_name_tag}".yellow

    image.registries.each do |registry|
      image.tags.each do |tag|
        ron          = image.parts_join('/', registry['url'], registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
    end

    # show predicted push task commands:
      end
    end
    puts image.to_yaml
  end
end
