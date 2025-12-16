alias gs='git status'
alias openpr='gh pr create --web'
alias viewpr='gh pr view'
alias reload='omz reload'
alias sourceme='omz reload'
alias tf-dev='node ~/terrafaker/bin/dev.js'
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

# gcsquash(["--from <branch>"] <commit message>)
# Soft resets the current branch from the origin branch, stages the changes, and then commits
# with the given message. Defaults to main branch.
# https://stackoverflow.com/a/50880042
function gcsquash() {
	ORIGIN_BRANCH=`git_main_branch`
	if [[ $1 == "--from" ]] || [[ $1 == "-f" ]];
	then
		ORIGIN_BRANCH=$2
		shift
		shift
	fi

	git reset --soft $ORIGIN_BRANCH
	git add -A
	git commit -m "$@"
}
