# nix-build

Build a nix-container and upload it to a registry.

Assumes that you have a working nix installation in your container/worker, e.g. via `cachix/install-nix-action@v16`. The action builds the docker image by running `nix-build docker.nix` (see nix's [`dockerTools`](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-dockerTools) for details, `src` can override this).

The resulting image is pushed to `registry/path:tag`, where `registry` must be a registry the CI has access to using the `username` and `password` input. `path` determines the output path, while `tag` can be omitted (it will be set automatically to `latest` for `main` and `master`, otherwise be the same as the tag or branch that is being built). The `tag` variable can be used to override this behavior. The version of nixpkgs used to upload the image can be set via `nixpkgs`.

## Example

The example below uploads to the GitHub container registry ([ghcr.io](https://ghcr.io)). You will need to create a legacy access token (ideally restricted to only uploading packages, see the [official documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry) for details) and set your username/token as action secrets `REGISTRY_USERNAME` and `REGISTRY_PASSWORD`, respectively.

```yaml
name: Build and publish container image
on: [push]
jobs:
  build:
    name: Build and push application image
    runs-on: ubuntu-latest
    steps:
      - uses: cachix/install-nix-action@v16
        with:
          nix_path: nixpkgs=channel:nixos-22.04
      - uses: actions/checkout@v2
      - uses: 49nord/nix-container-build@v4
        with:
          registry: ghcr.io
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}
          path: ${{ secrets.REGISTRY_USERNAME }}/myapplication
```
