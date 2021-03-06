#!/bin/sh

msg()
{
  echo "$@"
}

err()
{
  echo 1>&2 "$@"
}

run()
{
  "$@" && return 0
  code=$?
  err "command \`$@' failed with exit status $code"
  exit $code
}

check_dist()
{
  dist="$(sed -n 's/^ID=//p' /etc/os-release)"
  case "$dist" in
    arch|manjaro)
      dist='arch'
      ;;
    linuxmint|ubuntu)
      dist='ubuntu'
      ;;
    *)
      err "unsuported distribution: $dist"
      dist=''
      return 1
      ;;
  esac
}

chdir_top()
{
  run cd "$cfgbindir/../.."
}

foreach_submodule()
{
  run git config --file=.gitmodules --list | sed -n 's/^submodule\.\([^".]\+\)\.path=\([^"]\+\)$/sub_name="\1" sub_path="\2"/p' |
  while read line
  do
    run eval "$line"
    "$@"
  done
}

if_submodule_valid()
{
  if [ ! -r "$sub_path/.git" ]
  then
    return
  fi
  "$@"
}

git_submodule()
{
  git --git-dir="$sub_path/.git" "$@"
}

