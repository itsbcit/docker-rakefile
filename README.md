# docker-rakefile
[![Build Status](https://travis-ci.org/itsbcit/docker-rakefile.svg?branch=master)](https://travis-ci.org/itsbcit/docker-rakefile)

Rakefile and libraries for managing Docker images

## How to use
### New Docker image repositories
Click the button "Use this template" in [the docker-template GitHub repository](https://github.com/itsbcit/docker-template) to create a new templated GitHub repository.

### Existing Docker image repositories
Download and overwrite the Rakefile in the existing code with [the latest release Rakefile](https://github.com/itsbcit/docker-rakefile/releases/latest/download/Rakefile).

### Exclude support files
Update `.gitignore` to exclude the Rakefile library and `.build_id` marker file.

`.gitignore`:
```
.build_id
lib
```
Or download [from the template git repository](https://github.com/itsbcit/docker-template/raw/master/.gitignore).

### Install Rakefile support files
`Rakefile` can be updated to the latest release version with [`rake update`](#update).

The majority of the Rakefile support code is contained in the `lib` directory, which should be excluded from individual Git repositories using this system. This way, the latest release code is always used.

See [`rake install`](#install)

This will pull the latest release of the `lib` support files from GitHub.

### Create metadata.yaml
`metadata.yaml` defines the layout and handling of the Docker image(s) in this repository.

A simple example for an image without versions or variants:
```yaml
---
image_name: template_test
org_name: bcit
labels:
  maintainer: "jesse@weisner.ca, chriswood.ca@gmail.com"
vars:
  tini_version: '0.18.0'
  de_version: '1.5'
  dockerize_version: '0.6.0'
```

Inside ERB templated files, these parameters are available as eg. `metadata['vars']['dockerize_version']` for global parameters or eg. `image.vars['dockerize_version']` for the image-specific version of the same parameter. It is usually safer to use the image-specific nomenclature.

### Normal usage workflow

1. Make `Dockerfile` changes in `Dockerfile.erb`
2. `rake template` to update or create `Dockerfile`s, version and variant directories, templated files, etc.
3. `rake build`
4. `rake tag`
5. `rake push` to push to Docker Hub (or other repos defined in [`metadata.yaml`](#Create_metadata.yaml`))

## Rake tasks
### install
Install the Rakefile support files from the [latest release](https://github.com/itsbcit/docker-rakefile/releases/latest).

`rake install`

### update
`Rakefile` self-update. This downloads and overwrites `Rakefile` with (the latest release)[https://github.com/itsbcit/docker-rakefile/releases/latest/download/Rakefile]

`rake update`

### template

`rake template` will create or overwrite Dockerfile(s) from ERB templates and copy any files listed for the versions and variants into their build directories.

### build
Builds the Docker image(s).

### tag
Adds standard and `metadata.yaml` configured tags to the image(s).

Standard tags:
* image_name:b(`build id`) eg. `mybusybox:b1567100182`
* image_name:latest

### push
Pushes all images and tags to Docker Hub and/or the repositores configured in `metadata.yaml`.

## metadata.yaml
Sample metadata.yaml with all options:

```
---
image_name: weebly
org_name: barbaz
labels:
  maintainer: jesse@weisner.ca
versions:
  '':
  '1.2.3':
    suffixes:
      - 'production'
    version_tags:
      - '1.2'
variants:
  '':
  bar:
  supervisord:
    vars:
      bar: qux
    files:
      - supervisor.conf
suffixes:
registries:
  - url: 'localhost:5000'
    org_name: barbaz
vars:
  tini_version: '0.18.0'
  de_version: '1.5'
  dockerize_version: '0.6.0'
files:
```
