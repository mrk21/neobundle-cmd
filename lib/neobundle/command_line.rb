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
      parser = self.option_parser
      parser.order!(args)
      command = args.shift.to_s.intern
      
      case command
      when :install, :clean, :list then
        @arguments[:command] = command
        parser.permute!(args)
      when :'', :help then
        parser.permute(['--help'])
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
    
    protected
    
    def option_parser
      desc = lambda do |str|
        lines = str.split(/\n/)
        indent = lines.map{|v| v.match(/^ +/).to_a[0].to_s.length}.min
        lines.map{|v| v[indent..-1].rstrip}.join("\n")
      end
      
      summary = lambda do |parser, name, description, pos|
        result = ' '*100
        result[0] = name.to_s
        result[pos+1] = desc[description]
        result = parser.summary_indent + result.rstrip
        parser.separator result
      end
      
      parser = OptionParser.new
      parser.summary_indent = ' '*3
      parser.summary_width = 25
      parser.version = NeoBundle::VERSION
      parser.banner = desc[<<-DESC]
        Usage: neobundle [--help] [--version]
                         [--vim=<path>] [--bundlefile=<path>] [--verbose=<level>]
                         <command>
      DESC
      
      parser.separator ''
      parser.separator 'commands:'
      begin
        pos = 9
        
        summary[parser, :install, <<-DESC, pos]
          Install the Vim plugins
        DESC
        
        summary[parser, :clean, <<-DESC, pos]
          Delete the unused Vim plugins
        DESC
        
        summary[parser, :list, <<-DESC, pos]
          Enumerate the Vim plugins
        DESC
        
        summary[parser, :help, <<-DESC, pos]
          Show this message
        DESC
      end
      
      parser.separator ''
      parser.separator 'options:'
      begin
        parser.on('-c <path>', '--vim=<path>', String, desc[<<-DESC]) do |v|
          Path to the vim command
        DESC
          @arguments[:config][:vim] = v
        end
        
        parser.on('-f <path>', '--bundlefile=<path>', String, desc[<<-DESC]) do |v|
          Path to the bundle file
        DESC
          @arguments[:config][:bundlefile] = v
        end
        
        parser.on('-V <level>', '--verbose=<level>', Integer, desc[<<-DESC]) do |v|
          Show the detail log
        DESC
          @arguments[:config][:verbose] = v
        end
      end
      
      parser.separator ''
      begin
        parser.on('-h', '--help', 'Show this message') do
          puts parser.help
          exit
        end
        
        parser.on('-v', '--version', 'Show version') do
          puts parser.ver
          exit
        end
      end
      
      parser.separator ''
      parser.separator 'return value:'
      begin
        pos = 3
        
        summary[parser, '0', <<-DESC, pos]
          Success
        DESC
        
        summary[parser, '1', <<-DESC, pos]
          Error
        DESC
        
        summary[parser, '2', <<-DESC, pos]
          No operation
        DESC
      end
      
      return parser
    end
  end
end
