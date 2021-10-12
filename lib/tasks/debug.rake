# frozen_string_literal: true

desc 'Debug rakefile objects'
task :debug do
  puts '*** Debug image objects ***'.green
  $images.each do |image|
    #next unless image.variant == ""
    puts "Image: #{image.build_name_tag}".yellow

    image.registries.each do |registry|
      unless registry['url'].respond_to?(:contains_public_registry?)
        puts "Skipping registry with invalid url: check metadata.yaml".red
        next
      end
      if registry['url'].contains_public_registry? && registry['org_name'].to_s.empty?
        puts "Not tagging to public registry \"#{registry['url']}\": set org_name #{registry['org_name']} for registry in metadata.yaml".red
      end
    end
    puts "Suffixes:"
    puts image.suffixes
    puts "Tags:"
    puts image.tags
  end
end
