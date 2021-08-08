# gitstatus.zsh

`gitstatus.zsh` is a plugin made for prompts - it tells you how many things have
changed since the last git commit in a repository.

## Why such a thing?

Frankly, it's because I needed something small and fast that would integrate
well with my (multi-line) prompt.

Is it useful? For me and probably a handful other people, yes.

## Getting Started

### Requirements

- zsh
- git
- awk

### Installation

Clone this repository locally, on your machine, for example:

```
git clone "https://github.com/xylous/gitstatus.zsh.git" gitstatus
```

## Usage

Add the following lines to your zshrc:

```zsh
source path/to/installation/gitstatus.plugin.zsh

function precmd()
{
    local gitstatus="$(gitstatus)"
    PS1="%F{blue}%~%F{default} ${gitstatus} $ "
}
```

`precmd()` is a zsh builtin function that executes a series of commands right
before the prompt is drawn. In this example, it updates the output of the
`gitstatus` script and then uses it in a prompt.

And of course, remember to replace `path/to/installation` with the actual path
to the program.

## Roadmap

- [ ] add screenshots
- [ ] cover more `git status` flags

## Contributing

Pull requests and issues are welcome.
