# frozen_string_literal: true

# returns output of ERB template in lib/snippets or local/snippets
def snippet(snippet_name, scope)
  snippets_file = "snippets/#{snippet_name}.erb"
  libdir = File.exist?("local/#{snippets_file}") ? 'local' : 'lib'
  template = "#{libdir}/#{snippets_file}"

  if File.exist?(template)
    output = ERB.new(File.read(template), 0, '<>-', '_snippet').result(scope)
  else
    output = ''
    puts "WARNING: snippet \"#{snippet_name}\" not found.".red
  end

  output
end
