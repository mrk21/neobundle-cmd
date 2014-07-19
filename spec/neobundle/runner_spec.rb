require 'spec_helper'

module NeoBundle
  describe NeoBundle::Runner do
    subject { Runner.new(self.script) }
    
    let(:script){Vimscript.new(vimrc: './spec/fixtures/vimrc/with_neobundle.vim')}
    
    before do
      ENV['_neobundle_root'] = Dir.pwd
      FileUtils.mkdir_p './tmp/after'
      FileUtils.mkdir_p './tmp/plugin'
      FileUtils.mkdir_p './tmp/bundle'
      File.write('./tmp/plugin/empty.vim','')
    end
    
    it { expect{subject}.to_not raise_error }
    
    context 'when the NeoBundle was not installed' do
      let(:script){Vimscript.new(vimrc: './spec/fixtures/vimrc/base.vim')}
      it { expect{subject}.to raise_error(NeoBundle::NeoBundleNotFoundError, 'NeoBundle not found!') }
    end
    
    describe '#install()' do
      subject { super().install }
      
      let(:script) do
        double('Vimscript', exec: self.result.split(/\n/).map{|v| v.strip}.join("\n"))
      end
      
      let(:result){''}
      
      it { expect{subject}.to_not raise_error }
      
      context 'when installed nothing' do
        let(:result){%[
           message
          [neobundle/install] Target bundles not found.
          [neobundle/install] You may have used the wrong bundle name, or all of the bundles are already installed.
        ]}
        it { expect{subject}.to raise_error(NeoBundle::OperationAlreadyCompletedError, 'Already installed!') }
      end
    end
    
    describe '#clean()' do
      subject { super().clean }
      
      let(:script) do
        double('Vimscript', exec: self.result.split(/\n/).map{|v| v.strip}.join("\n"))
      end
      
      let(:result){''}
      
      it { expect{subject}.to_not raise_error }
      
      context 'when deleted nothing' do
        let(:result){%[
          message
          [neobundle/install] All clean!
        ]}
        it { expect{subject}.to raise_error(NeoBundle::OperationAlreadyCompletedError, 'Already cleaned!') }
      end
    end
  end
end
