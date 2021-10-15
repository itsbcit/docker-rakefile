# frozen_string_literal: true

desc 'Debug rakefile objects'
task :debug do
  puts '*** Debug image objects ***'.green
  $images.each do |image|
    puts "Image: #{image.build_name_tag}".pink
    puts 'Rendered Tags:'.yellow
    puts image.tags

    # show predicted tag task commands:
    puts 'Build task'.yellow
    build_tag = image.build_name_tag
    puts "docker build -f #{image.dir}/Dockerfile -t #{build_tag} ."

    # show predicted tag task commands:
    puts 'Tag task:'.yellow
    image.registries.each do |registry|
      image.tags.each do |tag|
        ron          = image.parts_join('/', registry['url'], registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
        ron_name_tag = image.parts_join(':', ron_name, tag)
        puts "docker tag #{image.build_name_tag} #{ron_name_tag}"
      end
    end

    # show predicted push task commands:
    puts 'Push task:'.yellow
    image.registries.each do |registry|
      image.tags.each do |tag|
        ron          = image.parts_join('/', registry['url'], registry['org_name'])
        ron_name     = image.parts_join('/', ron, image.image_name)
        ron_name_tag = image.parts_join(':', ron_name, tag)
        puts "docker push #{ron_name_tag}"
      end
    end
  end
end
