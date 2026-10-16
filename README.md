# freecad-cli

This is a fork of [docker-freecad-cli](https://github.com/amrit3701/docker-freecad-cli) with some modifications, sometimes company specific.
In most cases it's all about keeping the image up to date. Images are published on github registry.

## Documentation

<https://wiki.freecad.org/FreeCAD_Docker_CLI_mode>

## Usage

Native flavor:

```bash
docker run --rm -v $(pwd):/data ghcr.io/igusdev/freecad-cli:1.1.4 FreeCADCmd <command>
```

AppImage flavor:

```bash
docker run --rm -v $(pwd):/data ghcr.io/igusdev/freecad-cli:appimage-1.1.4 freecad --console <command>
```

## Smoke test

`test/smoke.py` checks that the main modules import and that STEP/STL export works. CI runs it against every image before publishing:

```bash
docker run --rm -v $(pwd)/test:/test ghcr.io/igusdev/freecad-cli:1.1.4 FreeCADCmd /test/smoke.py
docker run --rm -v $(pwd)/test:/test ghcr.io/igusdev/freecad-cli:appimage-1.1.4 freecad --console /test/smoke.py </dev/null
```
