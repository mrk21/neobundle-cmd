# NeoBundle

[NeoBundle](https://github.com/Shougo/neobundle.vim "Shougo/neobundle.vim") command line tools.

## Installation

Add this line to your application's Gemfile:

    gem 'neobundle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install neobundle

## Setting

**1. Install the NeoBundle:**

```bash
$ mkdir -p ~/.vim/bundle
$ cd ~/.vim/bundle/
$ git clone https://github.com/Shougo/neobundle.vim
```

**2. Add the NeoBundle settings to the `~/.vimrc`:**

```VimL
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#rc('~/.vim/bundle/')
endif

NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'Shougo/vimshell.vim'
NeoBundle 'Shougo/unite.vim'
```

## Usage

The structure of the command line is shown below:

```bash
$ neobundle [--help] [--version]
            [--vim=<path>] [--vimrc=<path>]
            <command>
```

### commands

#### install

This command will install the vim plugins by the NeoBundle which is described the `~/.vimrc`.
It equals the `:NeoBundleInstall` vim command.

```bash
$ neobundle install
```

#### clean

This command will delete the vim plugins which is unused.
It equals the `:NeoBundleClean!` vim command.

```bash
$ neobundle clean
```

#### list

This command will enumerate the vim plugins which is installed.
It equals the `:NeoBundleList` vim command.

```bash
$ neobundle list
```

### options

#### --vim

This option designates the vim command location.

```bash
--vim=<path>
```

The default value is `vim`, and this case is searched from the `PATH` environment variable by the system.
Also, this value is able to overriden by the `NEOBUNDLE_CMD_VIM` environment variable.

#### --vimrc

This option designates the vimrc location.

```bash
--vimrc=<path>
```

The default value is shown below:

| platform | value |
| -------- | ----- |
| Mac OS X and Linux | $HOME/.vimrc |
| Windows | %HOME%\\\_vimrc |

Also, this value is able to overriden by the `NEOBUNDLE_CMD_VIMRC` environment variable.

## Contributing

1. Fork it ( https://github.com/mrk21/neobundle-cmd/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
