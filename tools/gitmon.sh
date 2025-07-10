#!/bin/bash

# gitmon init https://abc.git
# gitmon

function show_help() {
cat <<:EOF
Script to monitor changes on a git repository.
See: https://github.com/freedev-org/kernelvr

USAGE
  gitmon <command> [cmd-args]

COMMANDS
  init <url> [path]
    Shallow clone the given git repository on the URL to the path.

  add <path>
    Add a new path to monitor inside the git repository.

  remove <path>
    Remove the given path of the monitoration.

  list
    List all monitored paths and the number of new commits per path.

  next [path]
    See the next commit that you didn't see yet. If [path] is specified,
    show the next commit on the given monitored path.

  update [callback]
    Update all monitored paths with new commits. If a callback is given, the
    callback will be executed for each new commit.

    The callback is a bash code that will be evaluted replacing "{commit}"
    with the commit hash.

  help
    Show this help message.

EXAMPLE
  gitmon add kernel/bpf/
  gitmon add drivers/net/
  gitmon list
:EOF
}

function main() {
    local command="$1"
    shift 1

    case "$command" in
        init)
            cmd_init "$@"
            ;;
        add)
            cmd_add "$@"
            ;;
        remove)
            cmd_remove "$@"
            ;;
        update)
            cmd_update "$@"
            ;;
        list)
            cmd_list "$@"
            ;;
        next)
            cmd_next "$@"
            ;;
        ''|-h|--help|help)
            show_help
            ;;
        *)
            echo "Invalid command '$command'! See help: gitmon -h" >&2
            exit 1
            ;;
    esac
}

function cmd_init() {
    local url="$1"
    local path="$2"

    git clone --depth 100 "$url" $path
}

function cmd_add() {
    check_git

    local path="$1"
    if [ -z "$path" ]; then
        echo "Error: Argument 'path' is required. See help: gitmon -h" >&2
        exit 1
    fi

    local path_hash=$(strhash "$path")
    local config_path=".git/gitmon/$path_hash"
    mkdir -p "$config_path"

    git rev-list --max-count=10 HEAD -- "$path" > "$config_path/commits.log"
    local newest_commit=$(head -n1 "$config_path/commits.log")

    echo "$path;$newest_commit" > "$config_path/info"
}

function cmd_remove() {
    check_git

    local path="$1"
    if [ -z "$path" ]; then
        echo "Error: Argument 'path' is required. See help: gitmon -h" >&2
        exit 1
    fi

    local path_hash=$(strhash "$path")
    rm -rf ".git/gitmon/$path_hash"
}

function cmd_update() {
    check_git

    local callback="$@"
    local tempfile="$(mktemp)"

    git pull

    for path in .git/gitmon/*; do
        IFS=';' read -e filter_path newest_commit < "$path/info"

        git rev-list $newest_commit..HEAD -- $filter_path > $tempfile
        [ ! -s $tempfile ] && continue

        cat "$path/commits.log" >> $tempfile
        mv -f "$tempfile" "$path/commits.log"

        local newest_commit=$(head -n1 "$path/commits.log")
        echo "$filter_path;$newest_commit" > "$path/info"

        [ -z "$callback" ] && continue
        trigger_callback "$tempfile" $callback
    done
}

function cmd_list() {
    echo "New commits    Path"

    for config_path in .git/gitmon/*; do
        [ ! -d $config_path ] && continue

        local filter_path="$(cut -d';' -f1 $config_path/info)"
        local commits=$(wc -l $config_path/commits.log | cut -d' ' -f1)

        printf "%-15d%s\n" "$commits" "$filter_path"
    done
}

function cmd_next() {
    local path="$1"

    if [ ! -z "$path" ]; then
        local commits_file=".git/gitmon/$(strhash $path)/commits.log"
    else
        local commits_file=$(find .git/gitmon/ -name commits.log -not -empty)
    fi

    if [ ! -f "$commits_file" ]; then
        return 0
    fi

    local last_commit=$(tail -n1 $commits_file)
    git show "$last_commit"

    local tempfile=$(mktemp)
    head -n-1 $commits_file > $tempfile
    mv -f $tempfile $commits_file
}

function trigger_callback() {
    local filepath="$1"
    shift 1
    local callback="$@"

    while read -e commit; do
        local cmd="$(sed -E "s/\{commit\}/$commit/g")"
        eval "$cmd"
    done < $filepath
}

function check_git() {
    if [ ! -d ".git" ]; then
        echo "Error: This command can only be run inside a git repository's root directory." >&2
        exit 5
    fi
}

function strhash() {
    local hash_cmd=$(which md5sum md5 | head -n1)
    echo "$@" | $hash_cmd | cut -d' ' -f1
}

main "$@"
