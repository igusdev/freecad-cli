# freecad-cli

This is a fork of [docker-freecad-cli](https://github.com/amrit3701/docker-freecad-cli) with some modifications, sometimes company specific.
In most cases it's all about keeping the image up to date. Images are published on github registry.

## Documentation

<https://wiki.freecadweb.org/FreeCAD_Docker_CLI_mode>

## Usage

Native flavor:

```bash
docker run --rm -v $(pwd):/data ghcr.io/igusdev/freecad-cli:1.1rc2 FreeCADCmd <command>
```

AppImage flavor:

```bash
docker run --rm -v $(pwd):/data ghcr.io/igusdev/freecad-cli:appimage-1.1rc2 freecad --console <command>
```
