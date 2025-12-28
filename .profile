put-secret() {
  local service=${1}
  local name=${2}
  local value=${3}
  security add-generic-password -s "${service}" -a "${name}" -w "${value}"
}

get-secret() {
  local service=${1}
  local name=${2}
  security find-generic-password -s "${service}" -a "${name}" -w 2>/dev/null
  return $?
}

markdown-to-pdf() {
  command -v pandoc >/dev/null || brew install pandoc
  [ $# -lt 1 ] && {
    echo "md2pdf|gfm2pdf <markdown file> ..." 1>&2
    echo " converts given markdown files to pdf files, saving them alongside the given markdown files" 1>&2
    return 1
  }
  local type file base
  type="${1}" # "markdown" or "gfm"
  shift
  for file in "$@"; do
    [ -s "${file}" ] || {
      echo "not a file: ${file}" 1>&2
      continue
    }
    base=$(dirname "${file}")/$(basename "${file}" .md)
    pandoc --from="${type}" --to=pdf -o "${base}.pdf" "${file}"
  done
}

gfm2pdf() {
  markdown-to-pdf "gfm" "${@}"
}
alias gfm-to-pdf gfm2pdf
alias gfmtopdf gfm2pdf

md2pdf() {
  markdown-to-pdf "markdown" "${@}"
}
alias md-to-pdf md2pdf
alias mdtopdf md2pdf

mov2mp4() {
  command -v ffmpeg >/dev/null || brew install ffmpeg
  args=("$@")
  [ ${#args[@]} -eq 0 ] && {
    args=("$(ls -t -- *.mov | head -1)")
  }
  for file in "${args[@]}"; do
    [ -f "${file}" ] || {
      echo "File not found: ${file}"
      continue
    }
    file "${file}" | grep -qi quicktime || {
      echo "File not MOV: ${file}"
      continue
    }
    dir=$(dirname "${file}")
    name=$(basename "${file}" ".mov")
    ffmpeg -i "${file}" -vcodec h264 -acodec mp2 "${dir}/${name}.mp4"
  done
}

cdr() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  [ -d "${root}" ] || return 1
  cd "${root}" || return 1
  return 0
}

# show the current git branch in the prompt
# ZSH syntax
git_current_branch() {
  git branch 2>/dev/null | sed -n -e 's/^\* \(.*\)/\1/p'
}
decorate_git_branch_name_for_prompt() {
  name=$(git_current_branch)
  [ -n "${name}" ] && name="[${name}] "
  echo "${name}"
}
setopt PROMPT_SUBST
export PROMPT='%n@%m %1~ $(decorate_git_branch_name_for_prompt)%# '
