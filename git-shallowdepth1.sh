#!/bin/bash

# Copyright (C) 2019 Jewell, Daniel <https://github.com/danieldjewell/>
# Author: Jewell, Daniel <https://github.com/danieldjewell/>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This is quick and dirty and might break things.


# run git commands on the current directory to prune to depth=1 and for all submodules too

declare -i GLO_SIZE_BEFORE=0
declare -i GLO_SIZE_AFTER=0
declare -i GLO_SIZE_DIFF=0


confirm() {
# call with a prompt string or use a default
read -r -p "${1:-Are you sure? [y/N]} " response

case "$response" in
  [yY][eE][sS]|[yY])
    echo 1
    ;;
  *)
    echo 0
    ;;
esac
}


pruneGitDir()
{
cd $1
sizeBeforeBytes=$(du -sb $1 | cut -f1)
echo "Shallowing $1"

echo "GIT: Running FETCH to Depth=1"
git fetch --depth=1 -pP 

echo "GIT: Reflog expire all "
git reflog expire --expire=0 --all
sleep 2s

echo "GIT: Prune"
git prune --progress

echo "GIT: Prune-packed"
git prune-packed

echo "GIT: Repack (-adfF)"
git repack -adfF

echo "GIT: GC (--aggressive)"
git gc --aggressive
sleep 2s


gsm=$(git submodule)
gsms=$(git submodule | wc -l)
if [[ $gsms -gt 0 ]]; then
  #there is 1 or more submodule to address
  #git submodule foreach --recursive 'git-fetch --depth=1 -P'
  #git submodule foreach --recursive 'git-reflog expire --expire=0 --all'
  #git submodule foreach --recursive 'git-gc --aggressive'
  sleepTime=$(($gsms * 4))
  echo ".:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:."
  echo "+ + + + + + + + + + + + + + + + + + +"
  echo "+  S U B M O D U L E S   F O U N D  +"
  echo "+-----------------------------------+"
  echo "Cleaning $gsms submodules"
  echo "Pruning/Fetch to Depth=1"
  git submodule foreach --recursive 'git-fetch --depth=1 -pP'
  sleep $sleepTime
  echo "Reflog: Expire"
  git submodule foreach --recursive 'git-reflog expire --expire=0 --all'
  sleep $sleepTime
  echo "Prune"
  git submodule foreach --recursive 'git-prune --progress'
  sleep $sleepTime
  echo "Prune Packed"
  git submodule foreach --recursive 'git-prune-packed'
  sleep $sleepTime
  echo "Repack -adfF"
  git submodule foreach --recursive 'git-repack -adfF'
  sleep $sleepTime
  echo "git-gc: --aggressive"
  git submodule foreach --recursive 'git-gc --aggressive'
  sleep $sleepTime
  echo "Submodules Cleaned"
fi

sizeAfterBytes=$(du -sb $1 | cut -f1)
diffBytes=$(($sizeBeforeBytes - $sizeAfterBytes))

echo "Done cleaning $1"
echo "Size before: $sizeBeforeBytes"
echo "Size after: $sizeAfterBytes"
echo "Savings: $diffBytes"

GLO_SIZE_BEFORE+=sizeBeforeBytes
GLO_SIZE_AFTER+=sizeAfterBytes
GLO_SIZE_DIFF+=diffBytes
}

findAllGitReposFromCD()
{
  pwdFull=$(pwd -P)
  #IFS='\n'
  readarray allGits < <(find $pwdFull -type d -name '.git' -printf '%h\n')
  gitQty="${#allGits[*]}"
  #echo ${#allGits[@]}
  #echo ${#allGits[*]}
  #echo ${#allGits}

  echo "Found $gitQty different repositories"
  echo "Preparing to prune all repos"
  conf=$(confirm)
  # echo $conf
  if [[ $conf -eq 1 ]]; then

    for g in ${allGits[@]}; do
      echo $g
      pruneGitDir $g
      echo "----------"
      echo "Current Summary"
      echo "Total Bytes Before: $GLO_SIZE_BEFORE"
      echo "Total Bytes After: $GLO_SIZE_AFTER"
      echo "Total Bytes Saveed: $GLO_SIZE_DIFF"
    done

    echo "++++++++++"
    echo "Done!"
    echo "Total Command Summary"
    echo "Total Bytes Before: $GLO_SIZE_BEFORE"
    echo "Total Bytes After: $GLO_SIZE_AFTER"
    echo "Total Bytes Saveed: $GLO_SIZE_DIFF"
    echo "++++++++++++++++++++++++++++++++++"
  fi

}


cwd=$(pwd)
if [[ ! -d $cwd/.git ]]; then
  echo "Not a git repository"
  echo "finding all git repos from the cwd"
  findAllGitReposFromCD
  # need to do some looping
else
  echo "Current Directory is a GIT Repository"
  echo "Will prune $cwd"
  conf=$(confirm)
  if [[ $conf -eq 0 ]]; then
    echo "Action cancelled."
    exit
  fi

  sizeBeforeBytes=$(du -sb $cwd | cut -f1)
  pruneGitDir $cwd
  sizeAfterBytes=$(du -sb $cwd | cut -f1)
  diffBytes=$(($sizeBeforeBytes - $sizeAfterBytes))

  #GLO_SIZE_BEFORE+=sizeBeforeBytes
  #GLO_SIZE_AFTER+=sizeAfterBytes
  #GLO_SIZE_DIFF+=diffBytes

  #echo "Done cleaning $cwd"
  #echo "Size before: $sizeBeforeBytes"
  #echo "Size after: $sizeAfterBytes"
  #echo "Savings: $diffBytes"

  echo "----------"
  echo "Current Summary"
  echo "Total Bytes Before: $GLO_SIZE_BEFORE"
  echo "Total Bytes After: $GLO_SIZE_AFTER"
  echo "Total Bytes Saveed: $GLO_SIZE_DIFF"
  echo "----------------------------------"

fi






