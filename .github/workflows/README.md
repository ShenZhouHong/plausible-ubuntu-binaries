# Github Actions Workflows

This folder contains workflow files for [Github Actions](https://docs.github.com/en/actions) (GA). Github Actions is a continuous integration/continuous delivery (CI/CD) tool that can be used to automate builds and perform testing. This `README.md` file contains additional documentation relating to the GA workflows that are used by this repository, as well as development instructions on how to test GA workflows.

## The build-ubuntu-binary GA

The `build-ubuntu-binary.yml` github action performs the following three tasks. Upon a substantive commit to this repository, it creates a GA Runner that:

1. Builds the upstream Plausible source code.
2. Packages the build artifacts as `.tar.gz` and `.zip` compressed archives.
3. Uploads the compressed build artifacts as a Github release.

Releases can be found on the [releases page](https://github.com/ShenZhouHong/plausible-ubuntu-binaries/releases/).

## Local Development

It can be a little tricky iterating and testing GA workflows, because in order to test a workflow, a commit has to be pushed to the repository and then run. This can lead to broken GA commits being pushed, as the developer iterates upon the workflow. A much better way to approach GA development, is to run the workflows locally using a local task runner.

### Using nektos/act to run GA workflows locally

The best way to do this is to use [`act`](https://github.com/nektos/act), a tool to run GA workflows on your local machine with Docker. In order to develop GA workflows locally, first install Docker Engine, and then act.

* [Docker Engine](https://docs.docker.com/desktop/install/linux-install/)
* [nektos/act](https://github.com/nektos/act)

Please note that when installing act using the bash installation method (i.e. `install.sh`), the resulting act binary will be placed within a `bin/` directory in your current directory. In order for the act binary to be available on your `$PATH`, you will need to either add the binary's path manually to your `$PATH` *or* move it to a location that is globally available, like `/usr/bin/`.

Once act is installed, it must be run in the repository directory (e.g. `plausible-ubuntu-binaries/`). Act will aim to auto-discover the `.github/workflows/` directory on it's own. 

In order to test the workflows within the `plausible-ubuntu-binaries/` repository, you must execute `act` with a [Github personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) (e.g. `GITHUB_TOKEN`). This is because our workflows include actions which automatically interface with Github, such as creating a new release.

```bash
cd AnalyticCodebase
act -s GITHUB_TOKEN
```

The above command will request a Github personal auth token interactively, before proceeding to run all workflows.

### Using actionlint to statically analyse GA workflows

Another development tool that will be useful for working with GA workflows is [actionlint](https://github.com/rhysd/actionlint), a static analyser for Github Actions. Actionlint is available both via an [online checker](https://rhysd.github.io/actionlint/), as well as a separate [VSCode plugin](https://github.com/arahatashun/vscode-actionlint).

By using actionlint and act, the development velocity for GA workflows can be greatly increased.