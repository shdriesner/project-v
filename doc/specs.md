# Specs
This documents various specifications for this project.

## Structure for modules.
For building from / storing module(s) outside the target rootfs we will define a directory structure.

* All modules that you want to build should be in one directory.

```
path/to/some/dir/here/some-dir/
```

* Module directory will then contain a seperate directory for each module that you want to build.

```
some-dir/ ---> tools/
          ---> my-foo/
          ---> chemical-x/
```

* Each module directory will contain a BUILDMOD build file. (File will be used by `mkmod` to build the module and the packages under it.)

```
some-dir/ ---> tools/
               ---> BUILDMOD
          ---> my-foo/
               ---> BUILDMOD
          ---> chemical-x/
               ---> BUILDMOD
```

* Under each module that you want to build, you should place directories with the name of the package(s) that you want under them.

```
some-dir/ ---> tools/
               ---> BUILDMOD
               ---> hammer/
               ---> chisel/
               ---> spanner/
          ---> my-foo/
               ---> BUILDMOD
               ---> some-pkg-a/
               ---> some-pkg-b/
               ---> some-pkg-foo/
          ---> chemical-x/
               ---> BUILDMOD
               ---> some-pkg-a/
               ---> some-pkg-b/
               ---> some-pkg-foo/
```

* With your modules populated you should place the `BUILDPKG` spec file, as it helps `BUILDMOD` to build packages within that module.

```
some-dir/ ---> tools/
               ---> BUILDMOD
               ---> some-pkg-a/
                    |--> BUILDPKG
               ---> some-pkg-b/
                    |--> BUILDPKG
               ---> some-pkg-foo/
                    |--> BUILDPKG
          ---> my-foo/
               ---> BUILDMOD
               ---> some-pkg-a/
                    |--> BUILDPKG
               ---> some-pkg-b/
                    |--> BUILDPKG
               ---> some-pkg-foo/
                    |--> BUILDPKG
          ---> chemical-x/
               ---> BUILDMOD
               ---> some-pkg-a/
                    |--> BUILDPKG
               ---> some-pkg-b/
                    |--> BUILDPKG
               ---> some-pkg-foo/
                    |--> BUILDPKG
```

_Note: Just like Arch BUILDPKG's you can also place extra local files inside those directories as well._