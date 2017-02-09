# -*- encoding : utf-8 -*-
APP_ROOT = "/home/admin/apps/rollout_service/current"
puts "AppPath: #{APP_ROOT}"

worker_processes 1
working_directory APP_ROOT
listen 'unix://home/admin/apps/rollout_service/shared/pid/rollout_service.socket', backlog: 512
listen 9876, tcp_nopush: true
timeout 120
pid "var/unicorn.pid"

stderr_path "#{APP_ROOT}/log/unicorn-err.log"
#stdout_path "#{APP_ROOT}/log/unicorn-out.log"

# Rails breaks unicorn's logger formatting, reset it
# http://rubyforge.org/pipermail/mongrel-unicorn/2010-October/000732.html
Unicorn::Configurator::DEFAULTS[:logger].formatter = Logger::Formatter.new

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  begin
    ENV["BUNDLE_GEMFILE"] = File.join(APP_ROOT, 'Gemfile')
  rescue
    put "###### Reseting BUNDLE_GEMFILE failed ######"
  end
end

after_fork do |server, worker|

  child_pid = server.config[:pid].sub('.pid', ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")

  # Sending a QUIT signal to the old pid AFTER the last worker is up.
  if worker.nr == (server.worker_processes - 1)
    old_pid = "#{server.config[:pid]}.oldbin"
    if File.exists?(old_pid) && server.pid != old_pid
      begin
        old_process_id = File.read(old_pid).to_i
        puts "Sending SIG QUIT to: #{old_process_id}."
        Process.kill("QUIT", old_process_id)
      rescue Errno::ENOENT, Errno::ESRCH
        # someone else did our job for us
      end
    end
  end
end
