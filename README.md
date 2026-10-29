# GTK4 Cross compile for Windows

## Prebuilt images

Images can be found on [DockerHub](https://hub.docker.com/r/mglolenstine/gtk4-cross/tags) or [GitHub container repository](https://github.com/MGlolenstine/gtk4-cross/pkgs/container/gtk4-cross).

### Configured release milestones

The image workflow retains GTK 4.6, 4.8, 4.10, and 4.12 and adds these
milestones between GTK 4.12 and the current stable release, GTK 4.24
(checked October 2026):

| Image tag | GTK | libadwaita | Why this milestone |
|---|---|---|---|
| `gtk-4.14` | 4.14.5 | 1.5.8 | [New unified GL/Vulkan renderers, better antialiasing and fractional scaling](https://release.gnome.org/46/developers) |
| `gtk-4.18` | 4.18.6 | 1.7.12 | [Layout performance improvements; libadwaita toggle groups, wrap boxes and adaptive preview](https://release.gnome.org/48/developers) |
| `gtk-4.22` | 4.22.5 | 1.9.4 | [Native SVG rendering; libadwaita sidebar widgets](https://release.gnome.org/50/developers) |
| `gtk-4.24` | 4.24.1 | 1.10.0 | [Current stable GTK, with improved fractional-scale rendering and SVG widgets](https://release.gnome.org/51/developers) |

Each configuration builds a base image with the tag above and a Rust image
prefixed with `rust-` (for example, `rust-gtk-4.24`). The existing
`gtk-nightly` / `rust-gtk-nightly` configurations continue to follow `main`.
All stable release configurations, including GTK 4.6, 4.8, 4.10, and 4.12,
use Fedora 45. The nightly configuration retains Fedora 40. Builds use
Fedora's packaged MinGW Graphene rather than GTK's historical fallback
wraps, some of which track unreleased Graphene code. Tags become available
in the registries only after a successful run of the manually triggered
**Docker images** workflow.

### To pull from DockerHub

Example for GTK 4.8:

```bash
docker pull mglolenstine/gtk4-cross:rust-gtk-4.8
```

### To pull from GitHub container repository

Example for GTK 4.8:

```bash
docker pull ghcr.io/mglolenstine/gtk4-cross:rust-gtk-4.8
```

## Cross compilation

### Rust project

Create a container inside your project and run it

```bash
docker run -ti -v `pwd`:/mnt gtk4-cross-rust
```

If your Docker host uses SELinux and you're getting errors about Cargo.toml not being found when trying to build, you may need to add `:z` to the end of the volume mount path, like so:

```bash
docker run -ti -v `pwd`:/mnt:z gtk4-cross-rust
```

Then run `build` to build the project and `package` to package it into a directory with all needed dependencies.

### Archiving the executables

To create an archive from the directory, you could run the following commands:

```bash
dnf install -y zip
zip -qr package.zip package/*
rm -rf package
```

`package.zip` will be present in your project directory.

### GUI smoke example

[examples/gui-smoke](examples/gui-smoke) contains a small Rust GTK4/libadwaita
application with runtime version labels, a name entry, and a greeting counter.
The same source targets the oldest supported API subset. See its README for
build instructions and the Wine verification scope for the oldest and newest
stable pairs.

## Image building

To create required images, clone the repository and cd into the root.

To build any images other than the base one, you will need to have prebuilt the base image.

### Build script

There's a file `build_image.sh` present in the root of the repository.
It takes environment variables and one cmdline argument to build the image you want.

|ENV|Default|Description|
|---|---|---|
|GTK|"main"|GTK version to be built|
|ADW|"main"|ADW version to be built|
|FEDORA|"40"|Fedora base version; use `45` for all stable release configurations|
|BASE|"gtk4-cross-base-$GTK-$ADW"|Base image name for Docker, only used on images built on top of the base image|
|TAG|"$IMAGE-$GTK-$ADW"|A name set for the output image|

The script takes one argument, which can be
|Argument|Description|
|---|---|
|`base`|Which builds the base image.|
|`rust`|Which builds the rust image.|

For example, build the current stable GTK/libadwaita pair locally (base first):

```bash
GTK=4.24.1 ADW=1.10.0 FEDORA=45 TAG=gtk4-cross:gtk-4.24 bash build_image.sh base
BASE=gtk4-cross:gtk-4.24 TAG=gtk4-cross:rust-gtk-4.24 bash build_image.sh rust
```

## Image creation

If you want to create your own project builder

- create a new directory with your own name `gtk4-cross-<language>` (`<language>` should be replaced with whatever your project relies on and makes it recognisable)
- `cd` into the new directory
- create a file `build.sh` that's going to contain your building code.
- link `package.sh` from the root into the directory

```bash
ln ../package.sh package.sh
```

- create a new `Dockerfile`, and put in the following boilerplate to have a runnable container.

```docker
FROM gtk4-cross-base

ADD build.sh /usr/bin
RUN chmod +x /usr/bin/build.sh

ADD package.sh /usr/bin
RUN chmod +x /usr/bin/package.sh

CMD ["/bin/bash"]
```

- build the image

```bash
docker build gtk4-cross-<language> -t gtk4-cross-<language>
```

- use the image

```bash
docker run -ti -v `pwd`:/mnt gtk4-cross-<language>
```

- add a section about your new builder to this `README.md`
- contribute :)
