# frozen_string_literal: true

desc 'Template, build, tag, test'
task :default do
  Rake::Task[:template].invoke
  Rake::Task[:build].invoke
  Rake::Task[:test].invoke
  Rake::Task[:tag].invoke
end
