# NeoBundle CMD

[NeoBundle](https://github.com/Shougo/neobundle.vim "Shougo/neobundle.vim") command line tools.

## Installation

Add this line to your application's Gemfile:

    gem 'neobundle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install neobundle

## Setting

1\. Install the NeoBundle:

```bash
$ mkdir -p ~/.vim/bundle
$ cd ~/.vim/bundle/
$ git clone https://github.com/Shougo/neobundle.vim
```

2\. Add the NeoBundle settings to the `~/.vimrc`:

```VimL
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#rc('~/.vim/bundle/')
endif

NeoBundle 'Shougo/vimproc.vim', {
      \ 'build': {
      \   'windows': 'make -f make_mingw32.mak',
      \   'cygwin': 'make -f make_cygwin.mak',
      \   'mac': 'make -f make_mac.mak',
      \   'unix': 'make -f make_unix.mak',
      \ },
      \}

NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'Shougo/vimshell.vim'
NeoBundle 'Shougo/unite.vim'
```

## Usage

The structure of the command line is shown below:

```bash
$ neobundle [--help] [--version]
            [--vim=<path>] [--bundlefile=<path>] [--verbose=<level>]
            <command>
```

### commands

#### install

This command will install the Vim plugins by the NeoBundle which is described the bundle file.
It equals the `:NeoBundleInstall` Vim command.

```bash
$ neobundle install
```

#### clean

This command will delete the Vim plugins which is unused.
It equals the `:NeoBundleClean!` Vim command.

```bash
$ neobundle clean
```

#### list

This command will enumerate the Vim plugins by the NeoBundle which is described the bundle file.
It equals the `:NeoBundleList` Vim command.

```bash
$ neobundle list
```

### options

#### --vim

This option designates the `vim` command location.

```bash
-c <path>, --vim=<path>
```

The default value is `vim`, and this case is searched from the `PATH` environment variable by the system.
Also, this value is able to overriden by the `NEOBUNDLE_CMD_VIM` environment variable.

#### --bundlefile

This option designates the bundle file location.

```bash
-f <path>, --bundlefile=<path>
```

The default value is shown below:

| platform | value |
| -------- | ----- |
| Mac OS X and Linux | $HOME/.vimrc |
| Windows | %USERPROFILE%\\\_vimrc |

Also, this value is able to overriden by the `NEOBUNDLE_CMD_BUNDLEFILE` environment variable.

#### --verbose

This option is the Vim script log level. In the ordinary, do not need to use this option,
but for example, when wanted to trace the errors of the bundle file, this option will assist.

```bash
-V <level>, --verbose=<level>
```

The default value is 0.

## Contributing

1. Fork it ( https://github.com/mrk21/neobundle-cmd/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
