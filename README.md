# freecad-cli

This is a fork of [docker-freecad-cli](https://github.com/amrit3701/docker-freecad-cli) with some modifications, sometimes company specific.
In most cases it's all about keeping the image up to date. Images are published on github registry.

## Documentation

<https://wiki.freecadweb.org/FreeCAD_Docker_CLI_mode>

## Usage

```bash
docker run --rm -v $(pwd):/data ghcr.io/igusdev/freecad-cli:0.21.2 FreeCADCmd <command>
```
