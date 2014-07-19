source $_neobundle_root/spec/fixtures/vimrc/base.vim

if has('vim_starting')
  set runtimepath+=$_neobundle_root/vendor/neobundle.vim
  call neobundle#rc($_neobundle_root .'/tmp/bundle/')
endif
