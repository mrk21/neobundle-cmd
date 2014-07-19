require "neobundle/version"

module NeoBundle
  class Error < StandardError; end
  class VimscriptError < Error; end
  class NeoBundleNotFoundError < Error; end
  class OperationAlreadyCompletedError < Error; end
end

require 'neobundle/vimscript'
require 'neobundle/runner'
