PATH=~/bin/:$PATH
export HISTSIZE=100000
#PROMPT_COMMAND='history -a'
shopt -s histappend
export HISTFILESIZE=100000
export HISTCONTROL=ignorespace:erasedups

# https://www.metabase.com/docs/latest/operations-guide/environment-variables.html

mute() {
  $@ >/dev/null 2>/dev/null
}

die() {
  echo "$@"
  exit 1
}

deps() {
  for dep in "$@"; do
    mute which "$dep" || apt install -y "$dep" || die "$dep dependency missing"
  done
}

print-as() {
  if echo "$1" | grep -q "^[{\[]"; then
    echo "$1"
  elif echo "$1" | grep -q "^null$"; then
    echo -n "null"
  elif echo "$1" | grep -q  "^true$"; then
    echo -n "true"
  elif echo "$1" | grep -q "^false$"; then
    echo -n "false"
  elif echo "$1" | grep -q "^-\?[0-9]\+$"; then
    echo -n "$1"
  else
    echo -n "\"$1\""
  fi
}

bjo() {
  local acc=()
  if [[ "$1" == "-a" ]] ; then
    shift
    for p in "$@" ; do
      acc+=("$(print-as "${p}")")
    done
    echo -n "["; IFS=","; echo -n "${acc[*]}"; echo -n "]"; IFS=" "
  else
    for p in "$@" ; do
      IFS='=' read -ra PARAMS <<< $(echo "$p")
      acc+=("\"${PARAMS[0]}\":$(print-as "${PARAMS[1]}")")
    done
    echo -n "{"; IFS=","; echo -n "${acc[*]}"; echo -n "}"; IFS=" "
  fi
}


mb-setup() {
  deps jo httpie jq
  http :3000/api/setup \
       token=$(http :3000/api/session/properties | jq -r '.["setup-token"]') \
       user:=$(jo email=awesome@example.com\
                  first_name=asdf\
                  last_name=asdf\
                  password=lazyfox1) \
       prefs:=$(jo allow_tracking=false \
                   site_name=mysite)
}

mute which less || alias less=more
