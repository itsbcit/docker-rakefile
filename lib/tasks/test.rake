# frozen_string_literal: true

###
# These tests assume that the container has a defined command that stays running indefinitely.
# If the container runs a command without a wait loop, you'll have to redefine the whole testing procedure.

desc 'Test docker images'
task :test do
  # check that the build system is available
  build_system = Docker.new
  unless build_system.running?
    puts "#{build_system.name} is not running: sanity check failed.".red
    exit 1
  end

  puts '*** Testing images ***'.green
  $images.each do |image|
    # basic container test
    begin
      build_tag = image.build_name_tag
      puts "Image: #{build_tag}".pink
      container = `docker run --health-interval=2s -d #{build_tag}`.strip
      exit 1 unless $?.success?

      # wait for container state "running"
      state = ''
      exitcode = nil
      error = nil

      printf 'Waiting for container startup'
      10.times do
        state = `docker inspect --format='{{.State.Status}}' #{container}`.strip
        exitcode = `docker inspect --format='{{.State.ExitCode}}' #{container}`.strip
        error = `docker inspect --format='{{.State.Error}}' #{container}`.strip
        exit 1 unless $?.success?
        break if state == 'running'

        # if the docker container exited cleanly, it can't be tested, but that may be expected
        if state == 'exited' && exitcode == '0'
          puts "\nContainer entrypoint or command exited cleanly. This container doesn't stay running without arguments, so it needs a custom test.".yellow
          break
        end

        break if state == 'exited'

        printf '.'
        sleep 1
      end
      puts
      unless state == 'exited' && exitcode == '0'
        puts "Container failed to reach \"running\" state. Got \"#{state}\"".red
        puts "Container exit code: #{exitcode}".yellow
        puts "Container error message: #{error}".yellow
        puts '--- begin container logs ---'.yellow
        puts `docker logs #{container}`
        puts '--- end container logs ---'.yellow
        exit 1
      end

      # if the container has a health check, wait up to 20 seconds for it to be successful
      container_health = `docker inspect --format='{{.State.Health}}' #{container}`.strip
      hashealth = container_health != '<nil>'
      if hashealth
        printf 'Waiting for container healthy'
        health_status = ''
        20.times do
          health_status = `docker inspect --format='{{.State.Health.Status}}' #{container}`.strip
          exit 1 unless $?.success?
          break if health_status == 'healthy'

          printf '.'
          sleep 1
        end
        puts
        if health_status != 'healthy'
          puts "Container failed to reach \"healthy\" status. Got \"#{health_status}\"".red
          exit 1
        end
      end
      # end of basic container test

      ###
      # put your custom image tests here
      ###

      # end of container tests
    ensure
      sh "docker kill #{container}" if `docker inspect --format='{{.State.Status}}' #{container}`.strip == 'running'
      sh "docker rm #{container}"
    end
    puts "Testing image #{image.build_tag} successful.".green
  end
end
