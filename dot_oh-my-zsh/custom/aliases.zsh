alias gs='git status'
alias openpr='gh pr create --web'
alias reload='omz reload'
alias sourceme='omz reload'
function hidedotfiles() {
	defaults write com.apple.finder AppleShowAllFiles NO
	killall Finder /System/Library/CoreServices/Finder.app
	echo "Dot files are now hidden. You can also toggle hidden files in a Finder window with ⌘ + SHIFT + ."
}
function showdotfiles() {
	defaults write com.apple.finder AppleShowAllFiles YES
	killall Finder /System/Library/CoreServices/Finder.app
	echo "Dot files are now shown. You can also toggle hidden files in a Finder window with ⌘ + SHIFT + ."
}
alias showhiddenfiles='showdotfiles'
alias hidehiddenfiles='hidedotfiles'
alias timestamp="node -e 'console.log(new Date().toISOString())'"
alias ts='timestamp'
