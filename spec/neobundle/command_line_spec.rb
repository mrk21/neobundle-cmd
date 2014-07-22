require 'spec_helper'
require 'stringio'

module NeoBundle
  describe NeoBundle::CommandLine do
    subject do
      CommandLine.new(self.args.split(/\s+/))
    end
    
    let(:args){''}
    
    describe '#arguments()' do
      subject { super().arguments }
      
      describe 'install command' do
        let(:args){'install'}
        it { is_expected.to eq(command: :install, config: {}) }
      end
      
      describe 'clean command' do
        let(:args){'clean'}
        it { is_expected.to eq(command: :clean, config: {}) }
      end
      
      describe 'list command' do
        let(:args){'list'}
        it { is_expected.to eq(command: :list, config: {}) }
      end
      
      describe 'help or version' do
        before { $stderr = $stdout = StringIO.new }
        after { $stderr = STDERR; $stdout = STDOUT }
        
        ['', 'help', '--help', '-h', '--version'].each do |args|
          describe '"%s"' % args do
            let(:args){args}
            it { expect{subject}.to raise_error(SystemExit) }
          end
        end
      end
      
      describe 'options' do
        let(:args){'--vim=path1 --vimrc=path3 install --vimrc=path4 --vim=path2'}
        it do
          is_expected.to eq(
            command: :install,
            config: {
              vim: 'path2',
              vimrc: 'path4'
            }
          )
        end
      end
      
      describe 'invalid command' do
        let(:args){'invalid-command'}
        it { expect{subject}.to raise_error(NeoBundle::CommandLineError, 'Invalid command: invalid-command') }
      end
      
      describe 'invalid option' do
        let(:args){'--invalid-option'}
        it { expect{subject}.to raise_error(NeoBundle::CommandLineError, 'invalid option: --invalid-option') }
      end
    end
    
    describe '::run(&block)' do
      subject do
        begin
          CommandLine.run do
            self.exception
          end
        rescue SystemExit => e
          self.io.rewind
          return [e.status, self.io.read.strip]
        end
      end
      
      let(:exception){nil}
      let(:io){StringIO.new('','r+')}
      
      before { $stderr = self.io }
      after { $stderr = STDERR }
      
      context 'when became successful' do
        it {expect(subject[0]).to eq(0) }
      end
      
      context 'when the `NeoBundle::Error` was thrown' do
        let(:exception){raise NeoBundle::VimscriptError, 'VimscriptError message'}
        it { expect(subject[0]).to eq(2) }
        it { expect(subject[1]).to eq('VimscriptError message') }
        
        context 'when the `NeoBundle::Error` was thrown' do
          let(:exception){raise NeoBundle::OperationAlreadyCompletedError, 'OperationAlreadyCompletedError'}
          it { expect(subject[0]).to eq(4) }
          it { expect(subject[1]).to eq('') }
        end
      end
      
      context 'when the `SystemExit` was thrown' do
        let(:exception){abort 'abort message'}
        it { expect(subject[0]).to eq(1) }
        it { expect(subject[1]).to eq('abort message') }
      end
      
      context 'when the unknown exception was thrown' do
        let(:exception){raise StandardError, 'StandardError message'}
        it { expect(subject[0]).to eq(255) }
        it { expect(subject[1]).to match(/^#<StandardError: StandardError message>/) }
      end
    end
  end
end
