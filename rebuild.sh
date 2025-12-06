#!/usr/bin/env bash

[[ $# -gt 0 ]] && cd "$HOME/nix" && nh os switch . && {
  git add --all
  git commit --message "$* [$(
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system |
      grep current |
      awk '{$1=$1};1' |
      cut -d' ' -f1
  )]"
  git push --quiet
}
