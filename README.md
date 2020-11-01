# nix-build

Build a nix-container and upload it to a registry.

Assumes that you have a working nix installation in your container/worker, e.g. via `cachix/install-nix-action@v10`. The action builds the docker image by running `nix-build docker.nix` (see nix's [`dockerTools`](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-dockerTools) for details, `src` can override this).

The resulting image is pushed to `registry/path:tag`, where `registry` must be a registry the CI has access to using the `username` and `password` input. `path` determines the output path, while `tag` can be omitted (it will be set automatically to `latest` for `main` and `master`, otherwise be the same as the tag or branch that is being built). The `tag` variable can be used to override this behavior.

## Example

```yaml
jobs:
  build:
    name: Build and push application image
    runs-on: ubuntu-latest
    steps:
      - uses: cachix/install-nix-action@v10
      - uses: actions/checkout@v2
      - uses: 49nord/nix-container-build@v1
        with:
          registry: registry.example.com
          user: ci-user
          password: ${{ secrets.registry-password }}
          path: myproject/myapplication
```
