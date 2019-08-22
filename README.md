# docker-template

## Rake tasks
### template
`rake template` will create or overwrite Dockerfile(s)

### metadata.yaml
Sample metadata.yaml:
```
---
image_name: foo
labels:
  maintainer: jesse@weisner.ca
org_name: barbaz
versions:
  '1.2.3':
    suffixes:
      - '1.2-latest'
      - latest
  '1.0':
  '1.1':
variants:
  '':
  bar:
  supervisord:
    files:
      - supervisor.conf
suffixes:
registries:
  - 'localhost:5000'
vars:
  tini_version: '0.18.0'
  de_version: '1.5'
  dockerize_version: '0.6.0'
files:
```
