# frozen_string_literal: true

desc 'Push to Registry'
task :push do
  images.each do |image|
    puts "*** Pushing #{org_name}/#{image} to #{registry}".green
    puts "docker push #{registry}/#{org_name}/#{image}".pink
    tags.each do |tag|
      puts "*** Pushing #{org_name}/#{image}:#{tag} to #{registry}".green
      puts "docker push #{registry}/#{org_name}/#{image}-#{tag}".pink
    end
  end
end
