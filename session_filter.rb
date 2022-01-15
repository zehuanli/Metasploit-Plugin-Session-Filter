#
# $Id$
# $Revision$
#

module Msf

###
#
# This class hooks all session creation events and filter the sessions.
#
###

class Plugin::EventSessionFilter < Msf::Plugin

  $notify = false
  $auto_exit = false
  @@valid_session_time = []

  class SF_ConsoleCommandDispatcher
    include Msf::Ui::Console::CommandDispatcher

    def name
      "SessionFilter"
    end

    def initialize(driver)
      super(driver)
      print_line('Notify: ' + ($notify ? 'true' : 'false'))
      print_line('Auto exit: ' + ($auto_exit ? 'true' : 'false'))
    end

    def commands
      {
        "sf_notify" => "Toggle notification",
        "sf_autoexit" => "Toggle auto exit session",
        "sf_status" => "Show current configs",
      }
    end

    def cmd_sf_notify(*args)
      if args[0]
        $notify = args[0].downcase.to_s == 'true'
      else
        $notify = ! $notify
      end
      print_line($notify ? 'Notify: true' : 'Notify: false')
    end

    def cmd_sf_autoexit(*args)
      if args[0]
        $auto_exit = args[0].downcase.to_s == 'true'
      else
        $auto_exit = ! $auto_exit
      end
      print_line($auto_exit ? 'Auto exit: true' : 'Auto exit: false')
    end

    def cmd_sf_status(*args)
      print_line($notify ? 'Notify: true' : 'Notify: false')
      print_line($auto_exit ? 'Auto exit: true' : 'Auto exit: false')
    end
  end

  def on_session_initialized(session)
    # on open
    session.singleton_class.send(:attr_accessor, 'interacted')
    session.interacted = false
    begin
      if session.interacted
        print_status('Session ' + session.sid.to_s + ' interacted. All previous messages:')
      else
        @@valid_session_time << Time.new.in_time_zone('Pacific Time (US & Canada)').to_s
        while @@valid_session_time.length > 5
          @@valid_session_time = @@valid_session_time.drop(1)
        end
        if $notify
          # Send message through your own notification channel here
        end
        if $auto_exit
          session.shell_write("exit\n")
          session.kill
          print_warning('Session ' + session.sid.to_s + ' auto exited.')
        end
      end
    rescue => e
      print_error(e.message)
      session.kill
    end
  end

  def on_session_interact(session)
    if session.respond_to? :interacted
      session.interacted = true
    end
  end

  def on_session_output(session, output)
    # on output
  end

  def on_session_close(session, reason='')
    # on close
  end

  def on_session_fail(reason='')
    # on fail
  end

  def initialize(framework, opts = {})
    super
    $notify = self.opts['notify'] && self.opts['notify'].downcase.to_s == 'true'
    $auto_exit = self.opts['auto_exit'] && self.opts['auto_exit'].downcase.to_s == 'true'
    self.framework.events.add_session_subscriber(self)
    @@framework = self.framework
    add_console_dispatcher(SF_ConsoleCommandDispatcher)
    start_server
  end

  def cleanup
    self.framework.events.remove_session_subscriber(self)
    remove_console_dispatcher('SessionFilter')
    stop_server
  end

  def name
    "session_filter"
  end

  def start_server
    require 'socket'
    @@server_thread = Thread.start do
      @@server = TCPServer.new('127.0.0.1', 8000)
      print_line('SessionFilter TCP server started')
      loop do
        @@socket_thread = Thread.start(@@server.accept) do |socket|
          request = socket.gets
          path = request.split(' ')[1]
          if path == '/notify'
            $notify = ! $notify
            response = $notify ? 'Notify: true' : 'Notify: false'
          elsif path == '/exit'
            $auto_exit = ! $auto_exit
            response = $auto_exit ? 'Auto exit: true' : 'Auto exit: false'
          elsif path == '/clear'
            @@valid_session_time.clear
            response = 'ok'
          elsif path == '/status'
            response = ($notify ? 'Notify: true' : 'Notify: false') + "\n" +
                       ($auto_exit ? 'Auto exit: true' : 'Auto exit: false') + "\n" +
                       @@framework.jobs.length.to_s + "\n" +
                       @@framework.sessions.length.to_s + "\n" +
                       @@valid_session_time.to_s
          else
            response = 'ok'
          end

          response += "\n"
          socket.print "HTTP/1.1 200 OK\r\n" +
                       "Content-Type: text/plain\r\n" +
                       "Content-Length: #{response.bytesize}\r\n" +
                       "Connection: close\r\n"
          socket.print "\r\n"
          socket.print response
          socket.close
        end
      end
    end
  end

  def stop_server
    if @@server
      @@server.close
    end
    if @@server_thread
      Thread.kill(@@server_thread)
    end
    if defined?(@@socket_thread) and @@socket_thread
      Thread.kill(@@socket_thread)
    end
  end

end
end

