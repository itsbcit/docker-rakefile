# frozen_string_literal: true

# @ripienaar https://www.devco.net/archives/2010/11/18/a_few_rake_tips.php
# Brilliant.
def render_template(template, output, scope)
  tmpl = File.read(template)
  erb = ERB.new(tmpl, 0, '<>-')
  File.open(output, 'w') do |f|
    f.puts erb.result(scope)
  end
end

def render_inline_template(string, scope)
  raise "render_inline_template expects String, got #{string.class}" unless string.is_a?(String)

  ERB.new(string, 0, '<>-').result(scope)
end

def render_hash_values(data, scope)
  raise 'render_hash_values expects hash data' unless data.is_a?(Hash)

  rendered_data = {}
  data.each do |k,v|
    rendered_data[k] = render_inline_template(v, scope)
  end

  rendered_data
end

def render_array_values(data, scope)
  raise 'render_hash_values expects array data' unless data.is_a?(Array)

  rendered_data = []
  data.each do |v|
    rendered_data << render_inline_template(v, scope)
  end
  rendered_data
end
