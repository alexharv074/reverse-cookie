#!/usr/bin/env bash

if [ "$(uname -s)" == "Darwin" ] ; then
  if [ ! -x /usr/local/bin/gsed ] ; then
    echo "On Mac OS X you need to install gnu-sed:"
    echo "$ brew install gnu-sed"
    exit 1
  fi

  shopt -s expand_aliases
  alias sed='/usr/local/bin/gsed'
fi

cookiecutter_module_name="{{cookiecutter.module_name}}"

exclude_list=(
  --exclude .git
  --exclude venv
  --exclude .cookiecutter.json
)

usage() {
  echo "Usage: $0 [-h] -i INPUT -o OUTPUT [-E EXCLUDE1 [-E EXCLUDE2 ...]]"
  echo "E.g. $0 -i ./myproject -o ./cookiecutter-myproject"
  exit 1
}

get_opts() {
  local opt OPTARG OPTIND

  if [[ "$#" -eq 0 ]] ; then
    usage
    exit 1
  fi

  while getopts ":hi:o:E:" opt ; do
    case $opt in
      h) usage ;;
      i) source_repo="$OPTARG" ;;
      o) dest_repo="$OPTARG" ;;
      E) exclude_list+=("$OPTARG") ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        usage
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        usage
        ;;
    esac
  done

  if [[ -z "$source_repo" ]] || [[ -z "$dest_repo" ]] ; then
    echo "Both -i INPUT and -o OUTPUT options are required."
    usage
    exit 1
  fi
}

_readme() {
  echo "# $dest_repo"
  cat <<'EOF'

A cookiecutter template for a new bootstrap project.

# Usage

Create a new project:

```text
▶ brew install cookiecutter
▶ cookiecutter path/to/this/directory
```
EOF
}

_cookiecutter_json() {
  jq 'del(.["_template"])' "$source_repo"/.cookiecutter.json
}

_reverse_cookie() {
  jq -r 'del(.["_template"]) | to_entries | reverse[] | "\(.key)\t\(.value)"' "$source_repo"/.cookiecutter.json
}

_replace() {
  local key="$1"
  local search="$2"
  local file_name="$3"
  local replace="{{cookiecutter.$key}}"
  sed -i 's/'"$search"'/'"$replace"'/g' "$file_name"
}

_templatise() {
  local key value file_name

  _reverse_cookie | while read -r key value ; do
    grep -wlr "$value" "$dest_repo" | while read -r file_name ; do
      _replace "$key" "$value" "$file_name"
    done
  done
}

validate_source_repo() {
  if [[ ! -e "$source_repo"/.cookiecutter.json ]] ; then
    echo "Your source repo must have a file .cookiecutter.json"
    exit 1
  fi
}

create_repo() {
  local module_dir="$dest_repo"/"$cookiecutter_module_name"

  mkdir -p "$module_dir"

  (cd "$module_dir" && \
   rsync -av --progress "$source_repo" ./ ${exclude_list[*]})

  _readme             > "$dest_repo/README.md"
  _cookiecutter_json  > "$dest_repo/cookiecutter.json"

  _templatise

  (cd "$dest_repo" && git init && git add . && git commit -m "Initial commit")
}

main() {
  get_opts "$@"
  validate_source_repo
  create_repo
}

main "$@"
