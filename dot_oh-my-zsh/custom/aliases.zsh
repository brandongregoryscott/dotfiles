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
alias python='python3'

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

# wav2mp3 <file|directory> [bitrate]
# Converts a wav or directory of wav files to mp3s at the specified
wav2mp3() {
  local bitrate="${2:-320k}"
  local target="$1"

  if [[ -z "$target" ]]; then
    echo "Usage: wav2mp3 <file|directory> [bitrate]" >&2
    echo "  bitrate defaults to 320k" >&2
    return 1
  fi

  if [[ -f "$target" ]]; then
    # Single file
    [[ "$target" != *.wav ]] && { echo "Not a .wav file: $target" >&2; return 1; }
    echo "Converting: $target"
    ffmpeg -i "$target" -codec:a libmp3lame -b:a "$bitrate" "${target%.wav}.mp3"

  elif [[ -d "$target" ]]; then
    local wavs=("${(@f)$(find "$target" -maxdepth 1 -type f -iname '*.wav')}")
    if [[ ${#wavs[@]} -eq 0 ]]; then
      echo "No .wav files found in $target" >&2
      return 1
    fi
    local count=${#wavs[@]}
    local i=1
    for f in "${wavs[@]}"; do
      echo "[$i/$count] Converting: $(basename "$f")"
      ffmpeg -i "$f" -codec:a libmp3lame -b:a "$bitrate" "${f%.wav}.mp3"
      ((i++))
    done
    echo "Done. Converted $count files at $bitrate."

  else
    echo "Not found: $target" >&2
    return 1
  fi
}

# Usage: samplerename <folder> <base-name>
# Example: samplerename "/Users/Brandon/Music/Samples/WG PACK 1/Kicks" "Kick"
samplerename() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: samplerename <folder> <base-name> [--dry-run]"
    return 1
  fi

  local folder="$1"
  local base="$2"
  local dry=0

  [[ "$3" == "--dry-run" ]] && dry=1

  if [[ ! -d "$folder" ]]; then
    echo "Error: '$folder' is not a directory"
    return 1
  fi

  local -a files
  files=("$folder"/*(N.))

  if [[ ${#files} -eq 0 ]]; then
    echo "No files found in '$folder'"
    return 1
  fi

  # Pad width: 2 digits under 100 files, 3 digits for 100+
  local pad=2
  (( ${#files} >= 100 )) && pad=3

  local i=1
  local f
  for f in "${files[@]}"; do
    local ext="${f##*.}"
    # If the file has no extension, ext == f basename — skip the dot
    [[ "$ext" == "$f:t" ]] && ext=""
    [[ -n "$ext" ]] && ext=".$ext"

    local newname
    newname="$(printf "%s %0${pad}d%s" "$base" "$i" "$ext")"
    local dest="$folder/$newname"

    if (( dry )); then
      echo "'${f:t}' -> '$newname'"
    else
      mv -n -- "$f" "$dest" && echo "Renamed: $newname"
    fi
    ((i++))
  done

  if (( dry )); then
    echo "\nDry run — no files moved."
  else
    echo "\nDone. Renamed $((i-1)) files."
  fi
}

# Usage: wavstrip <file.wav>   or   wavstrip <folder>
# Strips all metadata chunks (INFO, LIST, id3, IXML, cue, etc.) from WAV files.
# With a folder, processes every .wav inside it.
#
# What gets removed:
#   INFO chunks — artist, title, date, genre, comment, etc.
#   LIST chunks — RIFF LIST metadata
#   id3 / ID3 chunks — embedded ID3 tags
#   IXML / iXML — broadcast/production metadata
#   cue  — cue markers
#   Everything non-audio that ffmpeg can drop
wavstrip() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: wavstrip <file.wav | folder> [--dry-run]"
    return 1
  fi

  local target="$1"
  local dry=0
  [[ "$2" == "--dry-run" ]] && dry=1

  local -a files
  if [[ -d "$target" ]]; then
    files=("$target"/*.wav(N.))
    files+=("$target"/*.WAV(N.))
    [[ ${#files} -eq 0 ]] && { echo "No .wav files found in '$target'"; return 1; }
  elif [[ -f "$target" ]]; then
    files=("$target")
  else
    echo "Error: '$target' is not a file or directory"
    return 1
  fi

  local tmp
  for f in "${files[@]}"; do
    tmp="${f:h}/.${f:t}-stripped.wav"

    if (( dry )); then
      echo "Would strip: ${f:t}"
    else
      ffmpeg -y -i "$f" -map_metadata -1 -c:a copy -fflags +bitexact -flags:v +bitexact -flags:a +bitexact "$tmp" 2>/dev/null \
        && mv "$tmp" "$f" \
        && echo "Stripped: ${f:t}"
    fi
  done

  (( ! dry )) && echo "\nDone. Stripped ${#files} file(s)."
}
