# docker-rakefile

Rakefile and libraries for managing Docker images

## How to use

### New Docker image repositories

Click "Use this template" (green button) in the [docker-template](https://github.com/itsbcit/docker-template) GitHub repository to create a new templated GitHub repository. You must be logged-in to GitHub to see this option.

### Existing Docker image repositories

Download and overwrite the Rakefile in the existing code with the [latest release Rakefile](https://github.com/itsbcit/docker-rakefile/releases/latest/download/Rakefile).

### Exclude support files

Update `.gitignore` to exclude the Rakefile library and `.build_id` marker file.

`.gitignore` contents:

```
.build_id
lib
```

Or download from the [docker-template](https://github.com/itsbcit/docker-template/raw/master/.gitignore) git repository.

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
registries:
  - url: docker.io
    org_name: bcit
vars:
  foo_version: '1.2.3'
```

Inside ERB templated files, these parameters are available as eg. `image.vars['foo_version']`. Labels, vars, and tags can all be ERB-templated with inline values, but note that the context is the image, so no `image.` prefix. This example will add a label `foo_version = 1.2.3`:

```yaml
labels:
  foo_version: '<%= vars['foo_version'] %>'
```

### Normal usage workflow

1. Make `Dockerfile` changes in `Dockerfile.erb`
1. `rake update` to pull down Rakefile and library updates
1. `rake` (runs [template](#template), [build](#build), [tag](#tag), and [test](#test))
1. `rake push` to push to Docker Hub (or other repos defined in [`metadata.yaml`](#create-metadatayaml))

## Rake tasks

### install

Install the Rakefile support files from the [latest release](https://github.com/itsbcit/docker-rakefile/releases/latest).

`rake install`

### update

`Rakefile` self-update. Download and overwrite the `Rakefile` with the [latest release](https://github.com/itsbcit/docker-rakefile/releases/latest/download/Rakefile)

`rake update`

Side-effect: also calls [install](#install)

### template

Create or overwrite Dockerfile(s) from ERB templates and render any templated files listed for the versions and variants into their build directories.

`rake template`

### build

Build the Docker image(s).

`rake build`

### tag

Add standard and `metadata.yaml` configured tags to the image(s).

`rake tag`

Standard tags:

* image_name:b(`build id`) eg. `mybusybox:b1567100182`
* image_name:latest

### push
Push all images and tags to Docker Hub and/or the repositores configured in `metadata.yaml`.

`rake push`

## metadata.yaml
Sample metadata.yaml with all options:

```yaml
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
suffixes:
registries:
  - url: 'localhost:5000'
    org_name: barbaz
vars:
  tini_version: '0.18.0'
  de_version: '1.5'
  dockerize_version: '0.6.0'
```
