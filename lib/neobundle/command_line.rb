require 'optparse'
require 'neobundle/runner'

module NeoBundle
  class CommandLine
    attr_reader :arguments
    
    def self.run
      begin
        if block_given? then
          yield
        else
          self.new.execute
        end
      rescue NeoBundle::Error => e
        $stderr.puts e.message unless e.instance_of? NeoBundle::OperationAlreadyCompletedError
        exit e.status
      rescue SystemExit => e
        exit e.status
      rescue Exception => e
        $stderr.puts e.inspect
        $stderr.puts e.backtrace
        exit 255
      else
        exit 0
      end
    end
    
    def initialize(args=ARGV)
      @arguments = {
        command: nil,
        config: {}
      }
      opt = OptionParser.new
      opt.version = NeoBundle::VERSION
      opt.banner = <<-SH.gsub(/^( {2}){4}/,'')
        Usage: neobundle [--help] [--version]
                         [--vim=<path>] [--vimrc=<path>]
                         <command>
        
        commands:
                install:
                        $ neobundle install
                
                clean:
                        $ neobundle clean
                
                list:
                        $ neobundle list
        
        options:
      SH
      
      opt.on('--vim=<path>','Path to the vim command.'){|v| @arguments[:config][:vim] = v}
      opt.on('--vimrc=<path>','Path to the vimrc.'){|v| @arguments[:config][:vimrc] = v}
      opt.order!(args)
      
      command = args.shift.to_s.intern
      case command
      when :install, :clean, :list then
        @arguments[:command] = command
        opt.parse!(args)
      when :'', :help then
        opt.parse(['--help'])
      else
        raise NeoBundle::CommandLineError, 'Invalid command: %s' % command
      end
    rescue OptionParser::ParseError => e
      raise NeoBundle::CommandLineError, e.message
    end
    
    def execute
      runner = Runner.new(self.arguments[:config])
      runner.send(self.arguments[:command])
    end
  end
end
