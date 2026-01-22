# dotfiles

Repo for my personal configuration files across machines, managed by [chezmoi](https://www.chezmoi.io/). Linking it here since I always forget what it's called when I need it.

```sh
# Change into the directory managed by chezmoi which should point to this remote repo
chezmoi cd

# Diff local vs. applied changes
chezmoi diff

# Apply local changes (be sure to reload shell after)
chezmoi apply && reload

# Commit and push the changes as you normally would
git add . && git commit -m "chore: update config"
```