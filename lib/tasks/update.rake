# frozen_string_literal: true

desc 'Update Rakefile to latest release version'
task :update do
  open('https://github.com/itsbcit/docker-rakefile/releases/latest/download/Rakefile') do |rakefile|
    File.open('Rakefile', 'wb') do |f|
      f.write(rakefile.read)
    end
  end
end
