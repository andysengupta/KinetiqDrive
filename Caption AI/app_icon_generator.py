#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Generate iOS/iPadOS app icons + Contents.json from a single source image.

• Command-line argument to specify the source file (PNG/JPG).
• Outputs to: ./App Icons Generated/AppIcon.appiconset
• Produces all standard iPhone/iPad sizes + ios-marketing (1024).
• Flattens transparency onto opaque background (default: white).
• Leaves corners square — iOS masks them automatically.
"""

import argparse
import json
import os
import sys
from pathlib import Path

from PIL import Image

# ------------ Config ------------

OUTPUT_PARENT = Path.cwd() / "App Icons Generated"
APPICONSET_DIR = OUTPUT_PARENT / "AppIcon.appiconset"

# Background used if the source image has transparency (Apple forbids alpha for App Store icons).
OPAQUE_BG = (255, 255, 255)  # white; change to your brand color if you want.

# Icon definitions (point size x scale -> pixel size) for iPhone/iPad + ios-marketing.
# Filenames are friendly but you can rename if you prefer.
ICON_SPECS = [
    # iPhone
    {"idiom": "iphone", "size_pt": "20x20",  "scale": "2x", "pixels": 40,  "filename": "iphone-notification-20@2x.png"},
    {"idiom": "iphone", "size_pt": "20x20",  "scale": "3x", "pixels": 60,  "filename": "iphone-notification-20@3x.png"},
    {"idiom": "iphone", "size_pt": "29x29",  "scale": "2x", "pixels": 58,  "filename": "iphone-settings-29@2x.png"},
    {"idiom": "iphone", "size_pt": "29x29",  "scale": "3x", "pixels": 87,  "filename": "iphone-settings-29@3x.png"},
    {"idiom": "iphone", "size_pt": "40x40",  "scale": "2x", "pixels": 80,  "filename": "iphone-spotlight-40@2x.png"},
    {"idiom": "iphone", "size_pt": "40x40",  "scale": "3x", "pixels": 120, "filename": "iphone-spotlight-40@3x.png"},
    {"idiom": "iphone", "size_pt": "60x60",  "scale": "2x", "pixels": 120, "filename": "iphone-app-60@2x.png"},
    {"idiom": "iphone", "size_pt": "60x60",  "scale": "3x", "pixels": 180, "filename": "iphone-app-60@3x.png"},

    # iPad
    {"idiom": "ipad",   "size_pt": "20x20",  "scale": "1x", "pixels": 20,  "filename": "ipad-notification-20@1x.png"},
    {"idiom": "ipad",   "size_pt": "20x20",  "scale": "2x", "pixels": 40,  "filename": "ipad-notification-20@2x.png"},
    {"idiom": "ipad",   "size_pt": "29x29",  "scale": "1x", "pixels": 29,  "filename": "ipad-settings-29@1x.png"},
    {"idiom": "ipad",   "size_pt": "29x29",  "scale": "2x", "pixels": 58,  "filename": "ipad-settings-29@2x.png"},
    {"idiom": "ipad",   "size_pt": "40x40",  "scale": "1x", "pixels": 40,  "filename": "ipad-spotlight-40@1x.png"},
    {"idiom": "ipad",   "size_pt": "40x40",  "scale": "2x", "pixels": 80,  "filename": "ipad-spotlight-40@2x.png"},
    {"idiom": "ipad",   "size_pt": "76x76",  "scale": "1x", "pixels": 76,  "filename": "ipad-app-76@1x.png"},
    {"idiom": "ipad",   "size_pt": "76x76",  "scale": "2x", "pixels": 152, "filename": "ipad-app-76@2x.png"},
    {"idiom": "ipad",   "size_pt": "83.5x83.5", "scale": "2x", "pixels": 167, "filename": "ipad-pro-app-83.5@2x.png"},

    # App Store (Marketing)
    {"idiom": "ios-marketing", "size_pt": "1024x1024", "scale": "1x", "pixels": 1024, "filename": "ios-marketing-1024.png"},
]

# ------------ Helpers ------------

def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate iOS/iPadOS app icons from a single source image.",
        epilog="Example: python app_icon_generator.py source_icon.png"
    )
    parser.add_argument(
        "source_image",
        type=str,
        help="Path to source icon image (ideally 1024×1024, PNG or JPG)"
    )
    parser.add_argument(
        "-o", "--output",
        type=str,
        default=None,
        help="Output directory (default: ./App Icons Generated)"
    )
    return parser.parse_args()

def validate_source_image(path: Path) -> Path:
    """Validate that the source image exists and is readable."""
    if not path.exists():
        print(f"Error: File not found: {path}", file=sys.stderr)
        sys.exit(1)
    if not path.is_file():
        print(f"Error: Not a file: {path}", file=sys.stderr)
        sys.exit(1)
    if path.suffix.lower() not in ['.png', '.jpg', '.jpeg']:
        print(f"Warning: File extension '{path.suffix}' is not .png or .jpg/.jpeg", file=sys.stderr)
    return path

def load_source_image(path: Path) -> Image.Image:
    img = Image.open(path).convert("RGBA")
    # If the image is not square, letterbox/pad to square without distortion.
    w, h = img.size
    size = max(w, h)
    if (w, h) != (size, size):
        bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        offset = ((size - w) // 2, (size - h) // 2)
        bg.paste(img, offset)
        img = bg
    return img

def remove_alpha(img: Image.Image, bg_rgb=(255, 255, 255)) -> Image.Image:
    """Flatten transparency onto an opaque background color."""
    if img.mode != "RGBA":
        return img.convert("RGB")
    background = Image.new("RGB", img.size, bg_rgb)
    background.paste(img, mask=img.split()[-1])  # use alpha as mask
    return background

def ensure_dirs():
    APPICONSET_DIR.mkdir(parents=True, exist_ok=True)

def save_resized(img: Image.Image, pixels: int, out_path: Path):
    """Resize with high quality and save PNG (no metadata)."""
    # Use Image.Resampling.LANCZOS for Pillow 10.0.0+ compatibility
    try:
        resample_filter = Image.Resampling.LANCZOS
    except AttributeError:
        resample_filter = Image.LANCZOS
    resized = img.resize((pixels, pixels), resample_filter)
    # Apple forbids alpha for marketing; we make all outputs opaque to be safe.
    opaque = remove_alpha(resized, OPAQUE_BG)
    opaque.save(out_path, format="PNG", optimize=True)

def build_contents_json() -> dict:
    images = []
    for spec in ICON_SPECS:
        images.append({
            "size": spec["size_pt"],
            "idiom": spec["idiom"],
            "filename": spec["filename"],
            "scale": spec["scale"],
        })
    return {
        "images": images,
        "info": {"version": 1, "author": "xcode"},
    }

# ------------ Main ------------

def main():
    global OUTPUT_PARENT, APPICONSET_DIR
    
    args = parse_args()
    src_path = Path(args.source_image)
    validate_source_image(src_path)
    
    # Update output paths if custom output directory is specified
    if args.output:
        OUTPUT_PARENT = Path(args.output)
        APPICONSET_DIR = OUTPUT_PARENT / "AppIcon.appiconset"
    
    print(f"Source image: {src_path}")
    print(f"Output directory: {APPICONSET_DIR}")
    print()
    
    img = load_source_image(src_path)

    # Warn if the source is smaller than 1024 (still works but not recommended).
    if max(img.size) < 1024:
        print(f"⚠️  Warning: Source image is {img.size[0]}×{img.size[1]}.", file=sys.stderr)
        print(f"   Apple recommends 1024×1024 or larger for best quality.", file=sys.stderr)
        print()

    ensure_dirs()

    # Generate all icons
    print("Generating app icons...")
    for spec in ICON_SPECS:
        out_file = APPICONSET_DIR / spec["filename"]
        save_resized(img, spec["pixels"], out_file)
        print(f"✔︎ {spec['filename']} ({spec['pixels']}×{spec['pixels']})")

    # Write Contents.json
    contents = build_contents_json()
    with open(APPICONSET_DIR / "Contents.json", "w", encoding="utf-8") as f:
        json.dump(contents, f, indent=2)
    print("\n✅ All done!")
    print(f"➜ Asset catalog created at:\n   {APPICONSET_DIR}")

if __name__ == "__main__":
    main()
