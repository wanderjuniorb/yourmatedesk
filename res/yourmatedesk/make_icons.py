"""Gera a logo e os ícones do YourMateDesk.

Uso: python3 res/yourmatedesk/make_icons.py   (a partir da raiz do repositório)
Requer Pillow e a fonte Inter (só para o logotipo com texto).
"""
import os
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PRIMARY = (112, 121, 242, 255)    # #7079F2 (GesCondo)
DEEP = (78, 86, 214, 255)         # #4E56D6
LAVENDER = (209, 211, 239, 255)   # #D1D3EF
SOFT = (161, 167, 241, 255)       # #A1A7F1
WHITE = (255, 255, 255, 255)
NAVY = (36, 40, 92, 255)          # #24285C


def draw_icon(size: int) -> Image.Image:
    S = 4
    W = size * S
    im = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    u = W / 100.0
    # fundo: quadrado arredondado com leve degradê vertical
    bg = Image.new("RGBA", (W, W))
    gd = ImageDraw.Draw(bg)
    for y in range(W):
        t = y / (W - 1)
        c = tuple(int(PRIMARY[i] + (DEEP[i] - PRIMARY[i]) * t) for i in range(3)) + (255,)
        gd.line([(0, y), (W, y)], fill=c)
    mask = Image.new("L", (W, W), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, W - 1, W - 1], radius=22 * u, fill=255)
    im.paste(bg, (0, 0), mask)

    # monitor de trás (o computador do cliente), em lavanda
    d.rounded_rectangle([30 * u, 18 * u, 84 * u, 56 * u], radius=6 * u, fill=SOFT)
    # monitor da frente (o seu), em branco
    d.rounded_rectangle([16 * u, 32 * u, 70 * u, 70 * u], radius=6 * u, fill=WHITE)
    d.rounded_rectangle([21 * u, 37 * u, 65 * u, 65 * u], radius=3 * u, fill=LAVENDER)
    # pé do monitor
    d.rectangle([39 * u, 70 * u, 47 * u, 77 * u], fill=WHITE)
    d.rounded_rectangle([30 * u, 76 * u, 56 * u, 81 * u], radius=2.5 * u, fill=WHITE)
    # cursor (controle remoto) apontando para a tela
    cx, cy = 36 * u, 42 * u
    arrow = [(0, 0), (0, 17), (4.2, 13), (7.2, 19.5), (10, 18.2), (7, 11.8), (12.5, 11.8)]
    pts = [(cx + x * u, cy + y * u) for x, y in arrow]
    d.polygon(pts, fill=PRIMARY)
    return im.resize((size, size), Image.LANCZOS)


def save_ico(path, sizes):
    big = draw_icon(256)
    big.save(path, sizes=[(s, s) for s in sizes])


def draw_logo(text_color, scale=2) -> Image.Image:
    H = 60 * scale
    icon = draw_icon(H)
    font_path = "/usr/share/fonts/opentype/inter/Inter-Bold.otf"
    f = ImageFont.truetype(font_path, int(30 * scale))
    tmp = ImageDraw.Draw(Image.new("RGBA", (10, 10)))
    w1 = tmp.textlength("YourMate", font=f)
    w2 = tmp.textlength("Desk", font=f)
    gap = 12 * scale
    W = int(H + gap + w1 + w2 + 4 * scale)
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    im.paste(icon, (0, 0), icon)
    d = ImageDraw.Draw(im)
    bb = d.textbbox((0, 0), "YourMateDesk", font=f)
    y = (H - (bb[3] - bb[1])) / 2 - bb[1]
    x = H + gap
    d.text((x, y), "YourMate", font=f, fill=PRIMARY)
    d.text((x + w1, y), "Desk", font=f, fill=text_color)
    return im


def main():
    res = os.path.join(ROOT, "res")
    assets = os.path.join(ROOT, "flutter", "assets")
    draw_icon(1024).save(os.path.join(res, "icon.png"))
    draw_icon(1024).save(os.path.join(res, "mac-icon.png"))
    for s, name in [(32, "32x32.png"), (64, "64x64.png"), (128, "128x128.png"), (256, "128x128@2x.png")]:
        draw_icon(s).save(os.path.join(res, name))
    save_ico(os.path.join(res, "icon.ico"), [16, 24, 32, 48, 64, 128, 256])
    save_ico(os.path.join(res, "tray-icon.ico"), [16, 24, 32])
    save_ico(os.path.join(ROOT, "flutter", "windows", "runner", "resources", "app_icon.ico"),
             [16, 24, 32, 48, 64, 128, 256])
    draw_icon(512).save(os.path.join(assets, "icon.png"))
    draw_logo(NAVY).save(os.path.join(assets, "logo.png"))
    draw_logo(NAVY).save(os.path.join(assets, "logo_light.png"))
    draw_logo(WHITE).save(os.path.join(assets, "logo_dark.png"))
    print("ok")


if __name__ == "__main__":
    main()
