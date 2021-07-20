This mirrors some git repos to a github account.

How to use it:
- clone this repo into your account
- remove all of my matrix entries and env settings from `.github/workflows/mirror.yml`
- pick a different minute of the hour (and maybe different hours) than I did to run the scheduled job
- for each repo you want to mirror, run `make id_rsa.unique-repo-name`.  For example, for my `grub2-fedora` repo, I ran `make id_rsa.grub2-fedora`
- add an appropriate matrix entry in `.github/workflows/mirror.yml`, such as:
  ```
          - remote: https://github.com/rhboot/grub2
            user: vathpela
            repo: grub2-fedora
            secret: ID_RSA_GRUB2_FEDORA
            branches: fedora-32 fedora-33 fedora-34 fedora-35 fedora-36 fedora-37
  ```
- add an `ID_RSA_UNIQUE_REPO_NAME` entry in the `env:` section near the bottom of `.github/workflows/mirror.yml`, like:
  ```
            ID_RSA_GRUB2: ${{ secrets.ID_RSA_GRUB2 }}
  ```
- on your clone of this repo, in the github UI, go to `Settings -> Secrets`, and add a secret with the title `ID_RSA_UNIQUE_REPO_NAME` and the contents from `id_rsa.unique-repo-name`
- clone the repo you want to keep mirrored
- in that repo's github UI, got to `Settings -> Deploy Keys`, and add a key
  with the title `mirror_to_github` and the contents from `id_rsa.unique-repo-name.pub`
