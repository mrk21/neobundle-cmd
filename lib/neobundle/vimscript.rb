require 'shellwords'
require 'open3'
require 'tempfile'
require 'erb'

module NeoBundle
  class Vimscript
    def initialize(config={})
      @config = {
        vim: 'vim',
        bundlefile: nil,
        verbose: 0,
      }
      @config.merge!(config)
      begin
        out, err, status = Open3.capture3('%s --version' % Shellwords.escape(@config[:vim]))
        unless out =~ /^VIM - Vi IMproved / and status == 0 then
          raise NeoBundle::VimCommandError, 'command is not vim!' 
        end
      rescue SystemCallError 
        raise NeoBundle::VimCommandError, 'vim command not found!'
      end
    end
    
    def exec(cmd, io=nil)
      raise NeoBundle::VimscriptError, 'Command is empty!' if cmd.to_s.strip.empty?
      is_displaying_log = @config[:verbose] > 0
      $stderr.puts '### Command: %s' % cmd if is_displaying_log
      
      log_file = Tempfile.open('neobundle-cmd_vimscript_exec')
      command = ERB.new(<<-SH).result(binding).gsub(/\s+/,' ').strip
        <%= Shellwords.escape @config[:vim] %> -u NONE -U NONE -i NONE -N -e -s -V1
          --cmd "
            <% unless @config[:bundlefile].to_s.strip.empty? then %>
              set verbosefile=<%= log_file.path %> |
              <%= @config[:verbose] %>verbose source <%= @config[:bundlefile] %> |
              set verbosefile= |
            <% end %>
            <%= cmd %>
          "
          --cmd "
            qall!
          "
      SH
      
      log_thread = Thread.new do
        while true do
          line = log_file.gets.to_s.chomp
          $stderr.puts line unless line.empty?
        end
      end
      
      stdin, stdout, stderr, process = Open3.popen3(command)
      result = []
      
      stderr.each_line do |line|
        line = line.chomp
        io.puts line unless io.nil?
        result.push line
      end
      
      process.join
      log_thread.kill
      log_file.close
      $stderr.print "\n\n" if is_displaying_log
      
      result = result.join("\n")
      raise NeoBundle::VimscriptError, result if process.value != 0
      result
    end
  end
end
