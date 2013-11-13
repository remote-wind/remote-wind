namespace :config do

  Rake::TaskManager.record_task_metadata = true

  desc "Interactivly set up enviromental variables in OS-X > 10.8"
  task :setenv do |task|
    STDOUT.puts task.full_comment

    unless /darwin/i.match(RUBY_PLATFORM)
      STDOUT.puts "Your system (#{RUBY_PLATFORM}) does not appear to be OS-X"
      STDOUT.puts %q{
          please add the following lines to your profile:
          export REMOTE_WIND_EMAIL='some email'
          export REMOTE_WIND_PASSWORD='passsword'
          export REMOTE_WIND_GEONAMES='useraname'
      }
      abort
    end

    #email = get_input('email', "Please enter an email adress to use for confirmations")
    #password = get_input('password', "Please enter a password for the seeded admin account")
    #geonames = get_input('geonames.org username', "Please enter geonames.org username")

    user_input = {
        :REMOTE_WIND_EMAIL => "test@example.com",
        :REMOTE_WIND_PASSWORD => "test",
        :REMOTE_WIND_GEONAMES => "geonames"
    }


    if /darwin/i.match(RUBY_PLATFORM)
      STDOUT.puts %q{
      Would you like to write the variables to launchd.conf?
      this makes them available in the desktop enviroment as well (requires reboot)
      (Y or any key to skip)}
      if STDIN.gets.strip == "Y" or "y"
        add_vars_to_launchd user_input
      end

    end

    STDOUT.puts "All done, you may need to restart your system."
  end

  def get_input(name, message)
    STDOUT.puts message
    input = STDIN.gets.strip

    unless input.blank?
      return input
    else
      STDOUT.puts "No #{name} entered."
      setenv(key, name, message)
      false
    end
  end

  def add_vars_to_launchd input

    conf = File.read("/etc/launchd.conf")
    launchd = File.open("/etc/launchd.conf",'a+') do |file|
      STDOUT.puts "writing to /etc/launchd.conf..."

      input.each do |k,v|
        unless /#{k}/.match conf
          line = "setenv #{k} '#{v}'"
          file.puts line
          STDOUT.puts line
        else
          STDOUT.puts "#{k} exists, skipping..."
        end
      end
    end

    STDOUT.puts "Would you like check the state of the launchd environment? (Y or any key to skip)"
    if STDIN.gets.strip == "Y" or "y"
      STDOUT.puts "\n" + "-" * 15
      STDOUT.puts %x{ launchctl export }
      STDOUT.puts "-" * 15 + "\n"
    end
  end

end
