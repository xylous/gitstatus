# gitstatus.zsh

`gitstatus` is a zsh plugin that you can add to your prompt to help you see what
you're doing in a git repository more easily.

## Why such a thing?

Frankly, it's because I needed something small and fast that would integrate
well with my (multi-line) prompt.

Is it useful? For myself at least, yes.

## Getting Started

### Requirements

- zsh
- git
- awk

### Installation

Run the following command:

```
git clone https://github.com/Insert-Creative-Name-Here/gitstatus.zsh.git
```

You can move the downloaded repository anywhere you want on your computer
afterwards.

## Usage

Add the following lines to your zshrc:

```zsh
function precmd()
{
    source path/to/installation/gitstatus.plugin.zsh
}
```

`precmd()` is a zsh builtin that executes a series of commands right before the
prompt is drawn.

NOTE: you will have to redefine your prompt to include the variable
`$GIT_STATUS`, which is exported to the environment by this plugin. Something
like this:

```zsh
PS1="%F{blue}%~%F{default} $GIT_STATUS $ "
```

## Roadmap

- [ ] Find a way to not source the script every time a new prompt is
drawn
- [ ] Add bash support
- [ ] Add screenshots

## Contributing

Pull requests and issues are welcome.
