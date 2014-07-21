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
      opt = OptionParser.new
      opt.version = NeoBundle::VERSION
      opt.order!(args)
      command = args.shift.to_s.intern
      case command
      when :install, :clean, :list then
        @arguments = {command: command}
      when :'', :help then
        opt.parse(['--help'])
      else
        raise NeoBundle::CommandLineError, 'Invalid command: %s' % command
      end
    rescue OptionParser::ParseError => e
      raise NeoBundle::CommandLineError, e.message
    end
    
    def execute
      runner = Runner.new
      runner.send(self.arguments[:command])
    end
  end
end
