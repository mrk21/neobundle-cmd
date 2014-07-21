require 'neobundle/vimscript'

module NeoBundle
  class Runner
    attr_reader :script
    
    def self.default_config(platform = RUBY_PLATFORM)
      config = {
        vim: ENV['NEOBUNDLE_CMD_VIM'] || 'vim'
      }
      case platform
      when /darwin/,/linux/ then
        config.merge(vimrc: File.join(ENV['HOME'], '.vimrc'))
      when /mswin(?!ce)|mingw|cygwin|bccwin/ then
        config.merge(vimrc: File.join(ENV['HOME'], '_vimrc'))
      end
    end
    
    def initialize(config={}, script=nil)
      @script = script || Vimscript.new(self.class.default_config.merge(config))
      begin
        self.script.exec('NeoBundleList')
      rescue NeoBundle::VimscriptError
        raise NeoBundle::NeoBundleNotFoundError, 'NeoBundle not found!'
      end
    end
    
    def list
      @script.exec('NeoBundleList', $stdout)
    end
    
    def install
      dir = @script.exec('echo neobundle#get_neobundle_dir()')
      before = Dir['%s/*' % dir]
      @script.exec('NeoBundleInstall', $stdout)
      after = Dir['%s/*' % dir]
      raise NeoBundle::OperationAlreadyCompletedError, 'Already installed!' if before == after
    end
    
    def clean
      dir = @script.exec('echo neobundle#get_neobundle_dir()')
      before = Dir['%s/*' % dir]
      @script.exec('NeoBundleClean!', $stdout)
      after = Dir['%s/*' % dir]
      raise NeoBundle::OperationAlreadyCompletedError, 'Already cleaned!' if before == after
    end
  end
end
