def build_timestamp
    if ENV['timestamp'].nil?
      timestamp = Time.now.getutc.to_i
    else
      timestamp = ENV['timestamp']
    end

    return timestamp
end
