require 'neobundle/vimscript'

module NeoBundle
  class Runner
    attr_reader :script
    
    def self.default_config(platform = RUBY_PLATFORM)
      case platform
      when /darwin/,/linux/ then
        {vimrc: File.join(ENV['HOME'], '.vimrc')}
      when /mswin(?!ce)|mingw|cygwin|bccwin/ then
        {vimrc: File.join(ENV['HOME'], '_vimrc')}
      end
    end
    
    def initialize(script = Vimscript.new(self.class.default_config))
      @script = script
      begin
        self.script.exec('NeoBundleList')
      rescue NeoBundle::VimscriptError
        raise NeoBundle::NeoBundleNotFoundError, 'NeoBundle not found!'
      end
    end
    
    def install
      result = @script.exec('NeoBundleInstall')
      result = result.split(/\n|\r\n/)
      result = result.find{|v| v == '[neobundle/install] Target bundles not found.'}
      raise NeoBundle::OperationAlreadyCompletedError, 'Already installed!' unless result.nil?
    end
    
    def clean
      result = @script.exec('NeoBundleClean')
      result = result.split(/\n|\r\n/)
      result = result.find{|v| v == '[neobundle/install] All clean!'}
      raise NeoBundle::OperationAlreadyCompletedError, 'Already cleaned!' unless result.nil?
    end
  end
end
