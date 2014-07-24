require 'neobundle/version'
require 'rake/pathmap'

module NeoBundle
  class Error < StandardError; def status; 1 end end
  class VimCommandError < Error; end
  class VimscriptError < Error; end
  class NeoBundleError < Error; end
  class CommandLineError < Error; end
  class OperationAlreadyCompletedError < Error; def status; 2 end end
end

Dir[__FILE__.pathmap('%X/*.rb')].each do |rb|
  require rb.pathmap('%-1d/%n')
end
