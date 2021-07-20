#!/bin/bash
#
# mirror.sh - attempt to mirror rhboot/main to this repo's main branch

set -eu
set -x

function mirror-branch()
{
    local a_user=$1 && shift
    local b_user=$1 && shift
    local a_repo=$1 && shift
    local b_repo=$1 && shift
    local -a branches
    branches=("$@")

    local a_remote="${a_user}-${a_repo}"
    local b_remote="${b_user}-${b_repo}"

    git remote add "${a_remote}" "https://github.com/${a_user}/${a_repo}/"
    git fetch "${a_remote}"
    git remote add "${b_remote}" "git@github.com:${b_user}/${b_repo}"
    #git fetch "${b_remote}"

    for branch in "${branches[@]}" ; do
        local a_worktree="${a_user}-${a_repo}-${branch}"

        git worktree add "${a_worktree}" "${a_remote}/${branch}"
        cd "${a_worktree}"
        git push "${b_remote}" "+HEAD:${branch}"
        cd -
        rm -rf "${a_worktree}"
        git worktree prune
    done
    git remote remove "${a_remote}"
    git remote remove "${b_remote}"
}

cleanup() {
    rm -rf "$HOME/.ssh"
}

trap cleanup INT QUIT SEGV ABRT ERR

umask 0077
mkdir "$HOME/.ssh"
cat >"$HOME/.ssh/id_rsa" <<EOF
${MIRROR_TO_GITHUB}
EOF

mirror-branch rhboot vathpela shim mallory main

# vim:fenc=utf-8:tw=75
