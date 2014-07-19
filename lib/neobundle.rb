require "neobundle/version"

module NeoBundle
  class Error < StandardError; end
  class VimscriptError < Error; end
end

require 'neobundle/vimscript'
