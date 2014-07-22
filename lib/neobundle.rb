require 'neobundle/version'
require 'rake/pathmap'

module NeoBundle
  class Error < StandardError; def status; 1 end end
  class VimscriptError < Error; def status; 2 end end
  class NeoBundleNotFoundError < Error; def status; 3 end end
  class OperationAlreadyCompletedError < Error; def status; 4 end end
  class CommandLineError < Error; def status; 5 end end
  class VimCommandError < Error; def status; 6 end end
end

Dir['lib/neobundle/*.rb'].each do |rb|
  require rb.pathmap('%-1d/%n')
end
