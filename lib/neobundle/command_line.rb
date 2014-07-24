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
        exit 1
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
                         [--vim=<path>] [--bundlefile=<path>] [--verbose=<level>]
                         <command>
        
        commands:
                install:
                        $ neobundle install
                
                clean:
                        $ neobundle clean
                
                list:
                        $ neobundle list
                
                help:
                        $ neobundle help
        
        options:
      SH
      
      opt.on('-c <path>', '--vim=<path>', String, 'Path to the vim command') do |v|
        @arguments[:config][:vim] = v
      end
      
      opt.on('-f <path>', '--bundlefile=<path>', String, 'Path to the bundle file') do |v|
        @arguments[:config][:bundlefile] = v
      end
      
      opt.on('-V <level>', '--verbose=<level>', Integer, 'Show the detail log') do |v|
        @arguments[:config][:verbose] = v
      end
      
      opt.on_tail('-h', '--help', 'Show this message') do
        puts opt
        exit
      end
      
      opt.on_tail('-v', '--version', 'Show version') do
        puts opt.ver
        exit
      end
      
      opt.order!(args)
      command = args.shift.to_s.intern
      
      case command
      when :install, :clean, :list then
        @arguments[:command] = command
        opt.permute!(args)
      when :'', :help then
        opt.permute(['--help'])
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
