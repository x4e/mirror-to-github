#!/bin/bash
#
# mirror.sh - attempt to mirror specific branches of a git repo into a github git repo

set -eu
#set -x

if ! [ -v SSH_HOME ] ; then
    SSH_HOME=/home/runner
fi

cleanup() {
    rm -rf "${SSH_HOME}/.ssh"
}

mirror-branch()
{
    local a_url=$1 && shift
    local b_user=$1 && shift
    local b_repo=$1 && shift
    local b_secret=$1 && shift

    local -a branches
    branches=("$@")

    echo "mirroring ${a_url}"

    local a_remote="${a_url}"
    while [[ ${a_remote} =~ .*[][!@#$%^\&*()_=+{}\;:\'\"\<,\>\.\/\?].* ]] ; do
        for x in ~ \\\` \\\! @ \\\# \\\$ % ^ \\\& \\\* \\\( \\\) _ = + \
                 \\\[ \\\] \\\{ \\\} \
                 \\\; : \\\' \\\" \
                 "\\," \\\< . \\\> \\/ \\\?
        do
            a_remote="${a_remote/${x}/-}"
        done
        if [[ ${a_remote} =~ .*-$ ]] ; then
            a_remote="${a_remote:0:$((${#a_remote}-1))}"
        fi
    done
    while [[ "${a_remote}" =~ -- ]] ; do
        a_remote="${a_remote/--/-}"
    done

    local b_remote="${b_user}-${b_repo}"

    if [ -d "${SSH_HOME}" ] ; then
        trap cleanup INT QUIT SEGV ABRT ERR EXIT
        mkdir -p "${SSH_HOME}/.ssh"
        cat >"${SSH_HOME}/.ssh/id_rsa" <<EOF
$(IFS=$'\0' eval echo \$\{"${b_secret}"\})
EOF
    fi

    git remote add "${a_remote}" "${a_url}"
    git fetch "${a_remote}"
    git remote add "${b_remote}" "git@github.com:${b_user}/${b_repo}"
    #git fetch "${b_remote}"

    for branch in "${branches[@]}" ; do
        if ! [[ -f ".git/refs/remotes/${a_remote}/${branch}" ]] ; then
            echo "  no branch ${branch}"
            continue
        fi

        echo "  mirroring branch ${branch}"

        local a_worktree="${a_remote}-worktree"

        git worktree add "${a_worktree}" "${a_remote}/${branch}"
        cd "${a_worktree}"
        git push "${b_remote}" "+HEAD:${branch}"
        cd -
        rm -rf "${a_worktree}"
        git worktree prune
    done
    git remote remove "${a_remote}"
    git remote remove "${b_remote}"
    cleanup
    trap - INT QUIT SEGV ABRT ERR EXIT
}

umask 0077

mirror-branch https://github.com/rhboot/shim vathpela mallory ID_RSA_SHIM main

# vim:fenc=utf-8:tw=140
