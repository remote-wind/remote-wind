namespace :server do
  desc "Tasks realted to the builtin rails server"
  task kill: :environment do
    if File.file?(Rails.root + 'tmp/pids/server.pid')
      if system('kill -INT $(cat tmp/pids/server.pid)')
        puts "Server stopped."
      end
    else
      puts "could not find server.pid. Are you sure server is running? Exiting..."
    end
  end
end