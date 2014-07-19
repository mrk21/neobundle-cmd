require 'spec_helper'

module NeoBundle
  describe NeoBundle::Vimscript do
    subject { Vimscript.new(vimrc: 'NONE') }
    
    describe '#exec(cmd)' do
      subject { super().exec(self.cmd) }
      let(:cmd){'echo 1'}
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
    end
  end
end
