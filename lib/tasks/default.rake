desc "Template, build, tag, push"
task :default do
  Rake::Task[:Dockerfile].invoke
  Rake::Task[:build].invoke
  Rake::Task[:tag].invoke
  Rake::Task[:test].invoke
end
