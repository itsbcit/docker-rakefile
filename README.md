# docker-rakefile
[![Build Status](https://travis-ci.org/itsbcit/docker-rakefile.svg?branch=master)](https://travis-ci.org/itsbcit/docker-rakefile)

Rakefile and libraries for managing Docker images

## Rake tasks
### template
`rake template` will create or overwrite Dockerfile(s)

### metadata.yaml
Sample metadata.yaml:
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
