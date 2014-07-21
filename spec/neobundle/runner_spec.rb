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
        s = super()
        d = double('Vimscript')
        allow(d).to receive(:exec) do |cmd|
          if cmd == 'NeoBundleInstall' then
            self.on_install()
            ''
          else
            s.exec(cmd)
          end
        end
        d
      end
      
      let(:on_install) do
          File.write('./tmp/bundle/test.vim','')
      end
      
      it { expect{subject}.to_not raise_error }
      
      context 'when installed nothing' do
        let(:on_install){}
        it { expect{subject}.to raise_error(NeoBundle::OperationAlreadyCompletedError, 'Already installed!') }
      end
    end
    
    describe '#clean()' do
      subject { super().clean }
      
      let(:script) do
        s = super()
        d = double('Vimscript')
        allow(d).to receive(:exec) do |cmd|
          if cmd == 'NeoBundleClean!' then
            self.on_clean()
            ''
          else
            s.exec(cmd)
          end
        end
        d
      end
      
      let(:on_clean) do
        FileUtils.rm_f './tmp/bundle/test.vim'
      end
      
      before do
        File.write('./tmp/bundle/test.vim','')
      end
      
      it { expect{subject}.to_not raise_error }
      
      context 'when deleted nothing' do
        let(:on_clean){}
        it { expect{subject}.to raise_error(NeoBundle::OperationAlreadyCompletedError, 'Already cleaned!') }
      end
    end
    
    describe '::default_config([platform])' do
      subject { Runner.default_config(self.platform) }
      
      context 'when the platform was "Mac OS X"' do
        let(:platform){'x86_64-darwin13.0'}
        it do
          is_expected.to eq(
            vimrc: File.expand_path('~/.vimrc')
          )
        end
      end
      
      context 'when the platform was "Linux"' do
        let(:platform){'x86_64-linux'}
        it do
          is_expected.to eq(
            vimrc: File.expand_path('~/.vimrc')
          )
        end
      end
      
      context 'when the platform was "Windows"' do
        let(:platform){'x64-mingw32'}
        it do
          is_expected.to eq(
            vimrc: File.expand_path('~/_vimrc')
          )
        end
      end
    end
  end
end
