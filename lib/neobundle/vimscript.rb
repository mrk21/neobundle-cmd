require 'shellwords'

module NeoBundle
  class Vimscript
    MARK = '[neobundle-cmd/vim-script/command-part]'
    
    def initialize(config={})
      @config = {
        vim: 'vim',
        vimrc: 'NONE',
      }
      @config.merge!(config)
      begin
        vim = Shellwords.escape @config[:vim]
        result = %x[#{vim} --version]
        unless result =~ /^VIM - Vi IMproved / and $? == 0 then
          raise NeoBundle::VimCommandError, 'command is not vim!' 
        end
      rescue SystemCallError 
        raise NeoBundle::VimCommandError, 'vim command not found!'
      end
    end
    
    def exec(cmd, io=nil)
      raise NeoBundle::VimscriptError, 'Command is empty!' if cmd.to_s.strip.empty?
      command = (<<-SH % @config).gsub(/\s+/,' ').strip
        '%{vim}' -u '%{vimrc}' -U NONE -i NONE -e -s -V1
          -c "
            try |
              echo '#{MARK}' |
              #{cmd} |
              echo '#{MARK}' |
              echo '' |
            finally |
              q! |
            endtry
          "
          -c "
            echo '#{MARK}' |
            echo '' |
            q
          "
      SH
      r,w = IO.pipe
      process = Process.detach spawn(command, out: w, err: w)
      
      Thread.new do
        process.join
        r.close
        w.close
      end
      
      begin
        result = []
        is_outputting = false
        
        loop do
          line = r.gets.rstrip
          if line == MARK then
            is_outputting = !is_outputting
          elsif is_outputting then
            io.puts line unless io.nil?
            result.push line
          end
        end
      rescue IOError
        result = result.join("\n")
        raise NeoBundle::VimscriptError, result if process.value != 0
        result
      end
    end
  end
end
