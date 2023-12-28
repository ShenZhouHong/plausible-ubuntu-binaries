# Ubuntu Binaries for Plausible Analytics

[Plausible Analytics](https://plausible.io/) is an easy to use, lightweight (< 1 KB), open source and privacy-friendly alternative to Google Analytics. It doesn’t use cookies and is fully compliant with GDPR, CCPA and PECR. Plausible is developed by the team at [Plausible.io](https://plausible.io/), and their git repository can be found on Github [here](https://github.com/plausible/analytics/).

Plausible is an Elixir application written in Erlang, which uses an Elixir-based ecosystem of tooling that includes [Hex.pm](https://hex.pm/) (a package manager) and [Mix](https://hex.pm/docs/usage) (an Erlang build tool). Plausible also depends upon the Node Package Manager (i.e. `npm`) for front-end asset management. 

As a result, the Plausible source code is not ready-for-use, and must be compiled by the end-user. This compilation process can be non-trivial, especially for users without experience with Erlang or Elixir. The Plausible team does not provide compiled release binaries.

This repository provides an environment that creates compiled binaries for the Plausible Analytics application. These binaries are built and tested for Ubuntu 22.04, and should be compatible with any recent Ubuntu operating system. The intended audience and use case for these binaries are users who intend to self-host Plausible Analytics, either on their own server, or as a part of a custom containerization infrastructure.

**Disclaimer:** Please note that these binaries are *unofficial*, and this repository is *not* affiliated nor endorsed by the team at Plausible in any way.

## Pre-built Binaries

This repository automatically compiles release binaries using Github Actions (GA), a Continuous Integration (CI/CD) tool. You may find pre-built binaries as compressed `.tar.gz` and `.zip` archives via the releases page. Once again, be advised that these binaries are *unofficial*, and this repository is *not* affiliated nor endorsed by the team at Plausible.

* [Latest Release](https://github.com/ShenZhouHong/plausible-ubuntu-binaries/releases/latest)

For documentation relating to this repository's GA workflow, see the file at `.github/workflows/README.md`. You may directly access it via [this link](.github/workflows/README.md). 

Additionally, you may also choose to build your own binaries by cloning this repository, and running the build script on your own system. Instructions on how to do this are in the section below.

## Instructions for Building Binaries

In order to build Plausible, first ensure that git and Docker are available on your build system. First, clone this repository to your system.

```bash
git clone https://github.com/ShenZhouHong/plausible-ubuntu-binaries.git
cd plausible-ubuntu-binaries
```

### Initializing Git Submodules
This repository contains the Plausible source code (from [Plausible/Analytics](https://github.com/plausible/analytics/)) as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules), located at `src/` When cloning this repository for the first time, you must initialize and update the submodule in order to have Plausible's code available at `src/`

```bash
git submodule init
git submodule update
```

After initialising Plausible Analytic's source code as a git submodule, we are ready to build the Plausible binaries.

### Build Binaries

In order to build the binaries, run:

```bash
./build.sh
```

The bash script builds Plausible inside a Docker container environment, following instructions similar to the ones used upstream by the Plausible team. In the upstream source, Plausible builds their binaries using an [Alpine Linux](https://alpinelinux.org/) Docker container image from `hexpm/elixir:1.15.7-erlang-26.1.2-alpine-3.18.4`. We will be using a Ubuntu container image from `hexpm/elixir` with the same Erlang and Elixir versions.

Our Docker environment is defined at the `Dockerfile` located at the root of this repository. Note that we do *not* use the Dockerfile inside `src/`. After building the Plausible binary, the Dockerfile copies the build artefacts to a new release layer, which we then copy to `build/`.

### Release Artifacts

Once the build is complete, release artefacts will be made available at `build/`. This directory is ready to be packaged or deployed to any recent Ubuntu-based installation for use. The actual Plausible binary is located at `build/bin/plausible`, and can be run using:

```bash
chmod +x build/bin/plausible
cd build/bin/
./plausible
```

Please see Plausible's [documentation](https://plausible.io/docs/) for further information on use.

## To-Do

Some future improvements for the repository.

- [X] ~~Make pre-built binaries available for immediate download via Github's releases feature.~~ Completed.
- [X] ~~Build binaries automatically using Github Actions.~~ Completed.
- [ ] Create build environments for additional operating systems such as CentOS, RHEL, or FreeBSD.
- [ ] Properly track upstream SemVer versions instead of building on the main branch directly.

## License

Copyright for the Plausible Analytics source code (i.e. everything within the `src/` git submodule) is held by the team at [Plausible.io](https://plausible.io/), and [released under the terms of an AGPLv3 License](https://github.com/plausible/analytics/blob/master/LICENSE.md). The build tooling contained within this repository (i.e. `Dockerfile`, `build.sh`, and `.github/workflows/build-ubuntu-binary.yml`) are my own work, and they are [released under an AGPLv3 License](./LICENSE.md) as well. 