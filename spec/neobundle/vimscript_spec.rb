require 'spec_helper'
require 'stringio'

module NeoBundle
  describe NeoBundle::Vimscript do
    subject { Vimscript.new(self.config) }
    let(:config){{}}
    
    it { expect{subject}.to_not raise_error }
    
    context 'when the vim command not found' do
      let(:config){{vim: './not/existed/path'}}
      it { expect{subject}.to raise_error(NeoBundle::VimCommandError, 'vim command not found!') }
    end
    
    context 'when the command which is designated was not the "vim"' do
      describe 'output' do
        if ENV['OS'].nil?
          let(:config){{vim: './spec/fixtures/vim-command/non_vim.rb'}}
        else
          let(:config){{vim: './spec/fixtures/vim-command/non_vim.bat'}}
        end
        it { expect{subject}.to raise_error(NeoBundle::VimCommandError, 'command is not vim!') }
      end
      
      describe 'status' do
        if ENV['OS'].nil?
          let(:config){{vim: './spec/fixtures/vim-command/non_vim2.rb'}}
        else
          let(:config){{vim: './spec/fixtures/vim-command/non_vim2.bat'}}
        end
        it { expect{subject}.to raise_error(NeoBundle::VimCommandError, 'command is not vim!') }
      end
    end
    
    describe '#exec(cmd[, io])' do
      subject { super().exec(self.cmd, self.io) }
      let(:cmd){'echo 1'}
      let(:io){nil}
      
      it { is_expected.to eq('1') }
      
      context 'when the `cmd` was empty' do
        ['""', 'nil', '" \n  "'].each do |empty_cmd|
          describe empty_cmd do
            let(:cmd){eval empty_cmd}
            it { expect{subject}.to raise_error(NeoBundle::VimscriptError, 'Command is empty!') }
          end
        end
      end
      
      context 'when occured the Vim script error' do
        let(:cmd){'invalid-command'}
        it { expect{subject}.to raise_error(NeoBundle::VimscriptError, /E492:/) }
      end
      
      describe 'bundle file output' do
        subject do
          super()
          self.verbose_io.rewind
          self.verbose_io.read.chomp
        end
        
        let(:config) do
          {
            verbose: self.verbose_level,
            bundlefile: './spec/fixtures/vimrc/echo_log.vim'
          }
        end
        
        let(:verbose_level){0}
        let(:verbose_io){StringIO.new('','r+')}
        let(:message){'echo message'}
        
        before do
          $stderr = self.verbose_io
          ENV['_neobundle_root'] = Dir.pwd
          ENV['_neobundle_echo_message'] = self.message
        end
        
        after do
          $stderr = STDERR
          ENV['_neobundle_root'] = nil
          ENV['_neobundle_echo_message'] = nil
        end
        
        it { is_expected.to eq(self.message) }
        
        context 'when verbose level was 1' do
          let(:verbose_level){1}
          it { is_expected.to eq(['### Command: %s' % self.cmd, self.message, "\n"].join("\n")) }
        end
      end
      
      describe 'IO output' do
        subject do
          super()
          self.io.rewind
          self.io.read
        end
        
        let(:cmd){'echo 1 | echo 2'}
        let(:io){StringIO.new('','r+')}
        
        it { is_expected.to eq("1\n2\n") }
      end
    end
  end
end
