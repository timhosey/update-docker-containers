# we need a docker container/app name passed to us
# also need a password passed

# ARGV[0] is the server name
# ARGV[1] is the pass
# `echo "#{pass}" | sudo -S `
require 'yaml'
require 'json'
require 'open3'

def runCommands(commands, pw, container)
  data = {:out => [], :err => []}
  fail_count = 0
  echo_pass_cmd = "echo '#{pw}' | "
  commands.each do |step|
    if step[:action] == 'pull'
      new_img = false
      puts "* #{step[:description]}"
      stdout, stderr, status = Open3.capture3(echo_pass_cmd.to_s + step[:command])
      if stderr.include?("Pull complete")
        puts ".:. New image pulled. Continuing update."
      else
        puts ".:. No new image pulled. Skipping..."
        return 0
      end
    else
      puts "* #{step[:description]}"
      stdout, stderr, status = Open3.capture3(echo_pass_cmd.to_s + step[:command])
      if status.success? || stdout == ""
        puts ".:. SUCCESS: #{step[:success]}"
        if step[:action] == "prune" then puts stdout end
        if step[:action] == "test" then puts stdout end
      else
        puts ".:. FAIL: #{step[:failure]}"
        puts stderr
        fail_count += 1
      end
    end

    # stdout, stderr, status = Open3.capture3(echo_pass_cmd.to_s + cmd.to_s)
    
    # Fail check
    if !status.success?
      puts "\n\n"
      puts "*** Failed to run #{step} step successfully!"
      puts "*** Command: #{cmd}"
      puts "*** DEBUG: Status - #{status.to_s}"
      puts '*** Output of Failed Command:'
      puts stdout
      puts "\n\n"
      fail_count += 1
    end
  end
  return fail_count
end

containers = YAML.load_file('./docker-compose/server_containers.yaml')

# puts containers.inspect
Dir.chdir(containers[ARGV[0]]['compose_path']) do
  puts "===== STARTING UPDATE OF #{ARGV[0].upcase}. ====="
  containers[ARGV[0]]['basic_update'].each do |n|
    commands = [
      {
        "action": "pull",
        "command": "sudo -S -k docker-compose pull",
        "description": "Pulling image if updated.",
        "success": "Pulled latest image(s).",
        "fail": "Failed to pull latest image."
      },
      {
        "action": "down",
        "command": "sudo -S -k docker-compose down",
        "description": "Stopping container(s).",
        "success": "Stopped command issued successfully.",
        "fail": "Failed to stop container(s)."
      },
      {
        "action": "up",
        "command": "sudo -S -k docker-compose up -d",
        "description": "Bringing container(s) back up.",
        "success": "Up command issued successfully.",
        "fail": "Failed to issue start command."
      },
      {
        "action": "prune",
        "command": "sudo -S -k docker image prune -f",
        "description": "Pruning images.",
        "success": "Success! Images pruned.",
        "fail": "Images failed to prune."
      },
      {
        "action": "test",
        "command": "sudo -S -k docker-compose ps --services --filter \"status=running\"",
        "description": "Testing container(s) for status.",
        "success": "Container details are below. Check to ensure that all containers are listed.",
        "fail": "Failed to get container details."
      },
    ]
    Dir.chdir("./#{n}") do
      puts "*** Updating container: #{n} in #{Dir.pwd}"
      failures = runCommands(commands, ARGV[1], n)
      if failures > 0
        puts "*** Too many errors occurred. Failing run."
        exit 1
      end
      puts "*** Update process complete for #{n}."
    end
  end
  puts "===== UPDATE OF #{ARGV[0].upcase} COMPLETED. ====="
end