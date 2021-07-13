# Broad DSP SAST GitHub Action

## Usage

### Prerequisite

Ensure that the workflow contains steps to checkout and build Scala code with sbt.

For example: 
```
runs-on: ubuntu-latest
steps:
- name: Checkout
  uses: actions/checkout@v1
- name: Setup Scala
  uses: olafurpg/setup-scala@v10
  with:
    java-version: "adopt@1.8"
- name: Build and Test
  run: sbt -v -Dfile.encoding=UTF-8 +test
```

### SAST Action

This action does the following

- Install spotbugs and find-sec-bugs.
- Run a spotbugs scan for Scala code:
  - Assume conventional scala directory layout (see ```spotbugs-project.fbp``` file).
  - Enable find-sec-bugs plugin.
  - Include findings selected by appsec (see ```spotbugs-filter.xml``` file).
  - Generate output as SARIF.
- *TODO:* Insert SARIF findings into github security tab.
