# frozen_string_literal: true

def build_timestamp
  timestamp = if ENV['BUILD_ID'].nil?
                Time.now.getutc.to_i
              else
                ENV['BUILD_ID']
              end

  timestamp
end
