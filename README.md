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
    local gitstatus="$(path/to/installation/gitstatus.plugin.zsh)"
    PS1="%F{blue}%~%F{default} $gitstatus $ "
}
```

`precmd()` is a zsh builtin function that executes a series of commands right
before the prompt is drawn. In this example, it updates the output of the
`gitstatus` script and then uses it in a prompt.

And of course, remember to replace `path/to/installation` with the actual path
to the program.

## Roadmap

- [ ] Add screenshots

## Contributing

Pull requests and issues are welcome.
