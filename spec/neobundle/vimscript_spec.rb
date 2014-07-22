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
        let(:config){{vim: './spec/fixtures/vim-command/non_vim.rb'}}
        it { expect{subject}.to raise_error(NeoBundle::VimCommandError, 'command is not vim!') }
      end
      
      describe 'status' do
        let(:config){{vim: './spec/fixtures/vim-command/non_vim2.rb'}}
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
