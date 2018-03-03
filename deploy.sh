#!/usr/bin/env bash
# shellcheck disable=SC2181

BUILD_DIR='./_build'
GIT_DEPLOY_BRANCH="master"
GIT_DEPLOY_REPO="git@github.com:cmdse/cmdse.github.io.git"
export SPHINX_PRODUCTION=1

set -o errexit #abort if any command fails
me=$(basename "$0")
help_message="\
Usage: $me [-c FILE] [<options>]
Deploy generated files to a git branch.

Options:

  -h, --help               Show this help information.
  -v, --verbose            Increase verbosity. Useful for debugging.
  -s, --skip-build         Skip the SPHINX build phase
  -k, --keep-temp          Don't delete temporary folder on exit
  -m, --message MESSAGE    Specify the message used when committing on the
                           deploy branch.
  -n, --no-hash            Don't append the source commit's hash to the deploy
                           commit's message.
  -c, --config-file PATH   Override default & environment variables' values
                           with those in set in the file at 'PATH'. Must be the
                           first option specified.

Variables:

  BUILD_DIR           Relative or absolute path to SPHINX build directory
  GIT_DEPLOY_BRANCH   Commit deployable files to this branch.
  GIT_DEPLOY_REPO     Push the deploy branch to this repository.

These variables have default values defined in the script. The defaults can be
overridden by environment variables. Any environment variables are overridden
by values set in a '.env' file (if it exists), and in turn by those set in a
file specified by the '--config-file' option."

finish() {
  if [ -d "$temp_folder" ] && [ "$should_delete_temp" == "true" ] ; then
    rm -rf "$temp_folder"
    echo "Clean up temporary folder"
  fi
}

trap finish EXIT


git_deploy() {
  (cd "$deploy_directory" && git "$@")
}

init() {
	# Set args from a local environment file.
	if [ -e ".env" ]; then
    # shellcheck source=/dev/null
		source .env
	fi

	# Set args from file specified on the command-line.
	if [[ $1 = "-c" || $1 = "--config-file" ]]; then
    # shellcheck source=/dev/null
		source "$2"
		shift 2
	fi
  # Parse arg flags
	# If something is exposed as an environment variable, set/overwrite it
	# here. Otherwise, set/overwrite the internal variable instead.
	while : ; do
		if [[ $1 = "-h" || $1 = "--help" ]]; then
			echo "$help_message"
			exit 0
		elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
			verbose=true
			shift
		elif [[ $1 = "-s" || $1 = "--skip-build" ]]; then
			skip_build=true
			shift
		elif [[ $1 = "-k" || $1 = "--keep-temp" ]]; then
			should_delete_temp=false
			shift
		elif [[ ( $1 = "-m" || $1 = "--message" ) && -n $2 ]]; then
			commit_message=$2
			shift 2
		elif [[ $1 = "-n" || $1 = "--no-hash" ]]; then
			GIT_DEPLOY_APPEND_HASH=false
			shift
		else
			break
		fi
	done

	# Parse arg flags
	# If something is exposed as an environment variable, set/overwrite it
	# here. Otherwise, set/overwrite the internal variable instead.

	# Set internal option vars from the environment and arg flags. All internal
	# vars should be declared here, with sane defaults if applicable.

	# Source directory & target branch.
  build_dir=${BUILD_DIR}
	deploy_branch=${GIT_DEPLOY_BRANCH:-gh-pages}

  # Skip SPHINX build
  skip_build=${skip_build:-false}

	#if no user identity is already set in the current git environment, use this:
	default_username=${GIT_DEPLOY_USERNAME:-deploy.sh}
	default_email=${GIT_DEPLOY_EMAIL:-}

	#repository to deploy to. must be readable and writable.
	repo=${GIT_DEPLOY_REPO:-origin}

	#append commit hash to the end of message by default
	append_hash=${GIT_DEPLOY_APPEND_HASH:-true}
  build_root="html"
  should_delete_temp=${should_delete_temp:-true}
  deploy_directory=""
  temp_folder=""
}

build_deploy_folder() {
  if [ -d "$build_dir" ]; then
    rm -rf "$build_dir"
  fi

  if ! make html > /dev/null ; then
    echo Aborting due to failure in building project to html >&2
    exit 1
  fi
  echo "Sphinx build was successful :-)"
}

clone_in_temp_folder() {
  temp_folder=$(mktemp -d -t 'deploy-cmdse.XXXXX')
  if [ ! $? -eq 0 ] ; then
    echo Aborting due to failure in creating a temporary folder >&2
		exit 1
  fi
  echo "Created a temporary folder at $temp_folder"
  deploy_directory="$temp_folder"
  git clone -b "$deploy_branch" --quiet --single-branch "$repo" "$deploy_directory"
  if [ ! $? -eq 0 ] ; then
    echo Aborting due to failure in cloning git repository to temporary folder >&2
		exit 1
  fi
  echo "Cloned $repo with branch $deploy_branch successfully"
}

copy_build_to_temp() {
  rsync -rpc --ignore-times "$build_dir/$build_root/" "$temp_folder/"
  if [ ! $? -eq 0 ] ; then
    echo Aborting due to failure in copying build folder to git temp folder >&2
    exit 1
  fi
  echo "Copied build folder to git temp folder successfully"
}

prompt_user_for_changes() {
  echo "Git changes status:"
  (cd "$deploy_directory" && git status)
  git diff --exit-code --quiet
  if [ $? -eq 0 ] ; then
    echo "No changes to commit, aborting" >&2
    exit 1
  fi
  read -p "Do you want to stage, commit and push those changes? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      commit_and_push_changes
      return 0
  else
    echo "Aborting..." >&2
    exit 1
  fi
}

check_for_missing_git() {
  if ! git diff --exit-code --quiet --cached; then
    echo Aborting due to uncommitted changes in the index >&2
    exit 1
  fi
}

commit_and_push_changes() {
  commit_title=$(git log -n 1 --format="%s" HEAD)
  commit_hash=$(git log -n 1 --format="%H" HEAD)

  #default commit message uses last title if a custom one is not supplied
  if [[ -z $commit_message ]]; then
    commit_message="publish: $commit_title"
  fi

  #append hash to commit message unless no hash flag was found
  if [ "$append_hash" = true ]; then
    commit_message="$commit_message"$'\n\n'"generated from commit $commit_hash"
  fi

  git_deploy add --all
  commit+push
}


main() {
	init "$@"
  if [ "$skip_build" == "false" ]; then
    build_deploy_folder
  fi
  clone_in_temp_folder
  copy_build_to_temp
	enable_expanded_output
  check_for_missing_git
  prompt_user_for_changes
  exit 0
}

commit+push() {
	set_user_id
	git_deploy commit -m "$commit_message"

	disable_expanded_output

	#--quiet is important here to avoid outputting the repo URL, which may contain a secret token
	git_deploy push --quiet "$repo" "$deploy_branch"
  if [ $? -eq 0 ] ; then
    echo "Successfully pushed moficiation to remote $repo:$deploy_branch"
  else
    echo "Failed to push modifications, aborting..." >&2
    exit 1
  fi

	enable_expanded_output
}

#echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
	if [ "$verbose" ]; then
		set -o xtrace
		set +o verbose
	fi
}

#this is used to avoid outputting the repo URL, which may contain a secret token
disable_expanded_output() {
	if [ "$verbose" ]; then
		set +o xtrace
		set -o verbose
	fi
}

set_user_id() {
	if [[ -z $(git config user.name) ]]; then
		git_deploy config user.name "$default_username"
	fi
	if [[ -z $(git config user.email) ]]; then
		git_deploy config user.email "$default_email"
	fi
}

filter() {
	sed -e "s|$repo|\$repo|g"
}

sanitize() {
	"$@" 2> >(filter 1>&2) | filter
}

[[ $1 = --source-only ]] || main "$@"
