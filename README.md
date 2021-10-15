# docker-rakefile

Rakefile and libraries for managing Docker image builds

## How to use

### New Docker image repositories

Click "Use this template" (green button) in the [docker-template](https://github.com/itsbcit/docker-template) GitHub repository to create a new templated GitHub repository. You must be logged-in to GitHub to see this option.

### Existing Docker image repositories

Update the Rakefile and support library in the existing code with [rake update](#update).

### Exclude support files

Update `.gitignore` to exclude the Rakefile library and `.build_id` marker file.

`.gitignore` contents:

```text
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

Inside ERB templated files, these parameters are available as eg. `image.vars['foo_version']`. Eg in a Dockerfile.erb:

```erb
RUN yum install \
      foo-<%= image.vars['foo_version'] %>
```

Labels, vars, and tags can all be ERB-templated with inline values, but note that the context is the image, so no `image.` prefix. This example will add a label `foo_version = 1.2.3` using the value of `foo_version` from the image vars:

```yaml
labels:
  foo_version: '<%= vars['foo_version'] %>'
```

Important: parameters are rendered in the order: vars -> labels -> tags.

* vars can only include replacements from the image top-level, and other non-templatable image properties
* labels can include vars
* tags can include vars and labels

### Custom image handling

Any file in `lib` can be overridden by the same file name in `local/`. For example, if you need a custom [test](#test) task, copy `lib/tasks/test.rb` to `local/tasks/test.rb` and modify it.

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

`Rakefile` self-update. Download and overwrite the `Rakefile` and `libs` directory with the [latest release](https://github.com/itsbcit/docker-rakefile/releases/latest)

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

### test

Run automated tests against the image(s).

### push

Push all images and tags to Docker Hub and/or the repositores configured in `metadata.yaml`.

`rake push`

### clean

Removes all tags, images, "FROM images" and build context layers from Docker

### debug

Shows rendered tags, vars, labels, etc. Use to preview what your metadata will produce.

## metadata.yaml

Sample metadata.yaml with most options used:

```yaml
---
image_name: php-fpm
maintainer: 'jesse@weisner.ca, chriswood.ca@gmail.com'
labels:
  php_version: '<%= vars["php_version"] %>'
vars:
  pecl_oci8_version: '2.2.0'
  pecl_xdebug_version: '3.1.0'
  pecl_igbinary_version: '3.2.6'
  oracle_version: '18.3.0.0.0'
  oracle_major: '18.3'
variants:
  'builder':
    registries:
      - url: docker.io
        org_name: bcit
  '':
    registries:
      - url: docker.io
        org_name: bcit
  'oci':
    registries:
      - url: registry.example.com:5000
    labels:
      oracle_version: '<%= vars["oracle_major"] %>'
versions:
  '7.3':
    vars:
      php_version: '7.3.30'
  '7.4':
    vars:
      php_version: '7.4.24'
```
