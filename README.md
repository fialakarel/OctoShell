# OctoShell
Simple shell interface for OctoPrint


## Install

1. `git clone https://github.com/fialakarel/OctoShell.git`

2. Create settings
```bash
#!/bin/bash


# config file for OctoShell
# change api_key, IP and PORT

api_key="abc..."
printer="http://IP:PORT/api"

3. install `jq` cli JSON parser
```
sudo apt-get install jq
```

## Use it

* `./OctoShell.sh status`
* `./OctoShell.sh upload file.gcode [AnotherFile.gcode]`
* `./OctoShell.sh uploadprint file.gcode`
 

## Aliases
```bash
alias octoshell-status='~/OctoShell/OctoShell.sh status'
alias octoshell-watch='watch -n 5 ~/OctoShell/OctoShell.sh status'
alias octoshell-upload='~/OctoShell/OctoShell.sh upload'
alias octoshell-upload-print='~/OctoShell/OctoShell.sh uploadprint'
```
