module NeoBundle
  class Vimscript
    def initialize(config={})
      @config = {
        vim: 'vim',
        vimrc: '~/.vimrc',
        cmd: 'echo'
      }
      @config.merge!(config)
    end
    
    def exec(cmd)
      raise NeoBundle::VimscriptError, 'Command is empty!' if cmd.to_s.strip.empty?
      command = %[
        %{vim} -u %{vimrc} -U NONE -i NONE -c "
          try | %{cmd} | finally | q! | endtry
        " -c q -e -s -V1  2>&1
      ]
      command = command.gsub("\n",'') % @config.merge(cmd: cmd)
      result = [%x[#{command}], $?]
      raise NeoBundle::VimscriptError, result[0] if result[1] != 0
      result[0]
    end
  end
end
