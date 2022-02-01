# GTK4 Cross compile for Windows

## Image building

To create required images, clone the repository and cd into the root.

To build any images other than the base one, you will need to have prebuilt the base image.

### Base image

```bash
docker build gtk4-cross-base -t gtk4-cross-base
```

### Rust image

```bash
docker build gtk4-cross-rust -t gtk4-cross-rust
```

## Cross compilation

### Rust project

Create a container inside your project and run it

```bash
docker run -ti -v `pwd`:/mnt gtk4-cross-rust
```

Then run `build` to build the project and `package` to package it into a zip file.

`package.zip` will be present in your project directory.

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
