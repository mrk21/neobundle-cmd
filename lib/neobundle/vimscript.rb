module NeoBundle
  class Vimscript
    MARK = '[neobundle-cmd/vim-script/command-part]'
    
    def initialize(config={})
      @config = {
        vim: 'vim',
        vimrc: nil
      }
      @config.merge!(config)
    end
    
    def exec(cmd)
      raise NeoBundle::VimscriptError, 'Command is empty!' if cmd.to_s.strip.empty?
      config = @config.clone
      config[:vimrc] = '-u %s' % config[:vimrc] unless config[:vimrc].nil?
      command = (<<-SH % config).gsub(/\s+/,' ')
        %{vim} %{vimrc} -U NONE -i NONE -e -s -V1
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
      
      # The process surveillance.
      Thread.new do
        sleep 0.01 while process.status
        r.close
        w.close
      end
      
      # Read the command output.
      result = ''
      begin
        loop do
          result += r.gets
        end
      rescue IOError
      end
      
      raise NeoBundle::VimscriptError, result if process.value != 0
      r = result.split(/\r\n|\r|\n/)
      r = r[(r.index(MARK)+1)..(r.rindex(MARK)-1)]
      r.join("\n")
    end
  end
end
