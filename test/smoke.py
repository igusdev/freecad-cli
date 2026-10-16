import os
import sys
import tempfile

import FreeCAD
import Import
import Mesh
import MeshPart
import Part

print("FreeCAD", ".".join(FreeCAD.Version()[:3]))

box = Part.makeBox(10, 20, 30)
if abs(box.Volume - 6000) > 1e-6:
    sys.exit("unexpected box volume: %s" % box.Volume)

doc = FreeCAD.newDocument("smoke")
obj = doc.addObject("Part::Feature", "Box")
obj.Shape = box
doc.recompute()

with tempfile.TemporaryDirectory() as tmp:
    step = os.path.join(tmp, "box.step")
    stl = os.path.join(tmp, "box.stl")

    Import.export([obj], step)
    Mesh.export([obj], stl)
    MeshPart.meshFromShape(Shape=box, LinearDeflection=0.1)

    for path in (step, stl):
        if not os.path.exists(path) or os.path.getsize(path) == 0:
            sys.exit("export failed: %s" % path)

print("smoke test passed")
