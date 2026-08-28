from pathlib import Path
import tempfile
from PIL import Image, ImageDraw
import importlib.util

SCRIPT = Path(__file__).parents[1]/'scripts'/'detect_red_boxes.py'
spec=importlib.util.spec_from_file_location('detector', SCRIPT)
mod=importlib.util.module_from_spec(spec); spec.loader.exec_module(mod)

with tempfile.TemporaryDirectory() as td:
    p=Path(td)/'sample.png'
    im=Image.new('RGB',(240,180),'white')
    d=ImageDraw.Draw(im)
    d.rectangle((20,20,80,70), outline=(255,30,30), width=4)
    d.rectangle((130,90,210,150), outline=(245,50,50), width=5)
    im.save(p)
    result=mod.detect(str(p))
    assert result['image']=={'width':240,'height':180}
    assert len(result['boxes']) >= 2, result
print('PASS: red-box detector finds synthetic annotations')
