# Unit Testing Helm charts
Unit tests for the yugabyte helm charts, which can be used to validate helm templates
gives us our expected results.

This is leveraging https://github.com/helm-unittest/helm-unittest

See https://github.com/quintush/helm-unittest/blob/master/DOCUMENT.md for details on creating new
tests

## Install
```
$ helm plugin install https://github.com/helm-unittest/helm-unittest.git
```

## Run tests
```
$ cd stable/yugabyte
$ helm unittest -f "tests/test_*.yaml" .
```
