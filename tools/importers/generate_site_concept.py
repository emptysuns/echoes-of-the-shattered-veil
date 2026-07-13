#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parents[2]
W,H=1440,1200
im=Image.new('RGB',(W,H),'#090812'); d=ImageDraw.Draw(im)
hero=Image.open(ROOT/'site/assets/shattered_spire_panorama.png').convert('RGB').resize((1440,816),Image.Resampling.NEAREST)
im.paste(hero,(0,0)); d.rectangle((0,0,790,816),fill='#090812dd')
try: font=ImageFont.truetype(ROOT/'assets/fonts/ark-pixel-12px.ttf',52); small=ImageFont.truetype(ROOT/'assets/fonts/ark-pixel-12px.ttf',22)
except: font=None; small=None
d.text((105,150),'Echoes of the',font=small,fill='#83b6b3'); d.text((105,198),'Shattered Veil',font=font,fill='#f0e7cf'); d.text((105,278),'破碎帷幕的回响',font=small,fill='#d59a42')
d.rectangle((105,365,330,423),fill='#d59a42'); d.text((135,383),'DOWNLOAD',font=small,fill='#090812')
d.rectangle((0,816,W,1200),fill='#121126')
d.text((105,865),'Every death leaves the lie thinner.',font=small,fill='#f0e7cf')
for i,(title,color) in enumerate([('DESCEND','#d59a42'),('REMEMBER','#83b6b3'),('RETURN','#4b6f8f')]):
 x=105+i*410; d.rectangle((x,940,x+360,1125),outline='#4b6f8f',width=2); d.text((x+25,970),f'0{i+1}',font=small,fill=color); d.text((x+25,1030),title,font=small,fill='#f0e7cf')
im.save(ROOT/'docs/design/site-concept.png')
