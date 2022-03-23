# frozen_string_literal: true

desc 'Template, build, test, tag'
task :default do
  Rake::Task[:template].invoke
  Rake::Task[:build].invoke
  Rake::Task[:test].invoke
  Rake::Task[:tag].invoke
end
