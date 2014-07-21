require 'pp'
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
      mark = '[neobundle-cmd/vim-script/command-part]'
      command = %[
        %{vim} -u %{vimrc} -U NONE -i NONE -c "
          try | echo '#{mark}' | #{cmd} | echo '#{mark}' | finally | q! | endtry
        " -c q -e -s -V1  2>&1
      ]
      command = command.gsub("\n",'') % @config
      result = %x[#{command}]
      raise NeoBundle::VimscriptError, result if $? != 0
      r = result.split(/\r\n|\r|\n/)
      r = r[(r.index(mark)+1)..(r.rindex(mark)-1)]
      r.join("\n")
    end
  end
end
