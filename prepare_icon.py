from PIL import Image, ImageEnhance
import os

def prepare_app_icon(input_path, output_dir, base_size=1024, sizes=None):
    if sizes is None:
        sizes = [1024, 512, 256, 192, 180, 120, 96, 72, 48]

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    try:
        img = Image.open(input_path).convert("RGBA")
    except Exception as e:
        print(f"خطأ في فتح الصورة: {e}")
        return

    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(1.2)
    enhancer = ImageEnhance.Color(img)
    img = enhancer.enhance(1.1)

    img = img.resize((base_size, base_size), Image.LANCZOS)

    base_output_path = os.path.join(output_dir, f"app_icon_{base_size}x{base_size}.png")
    img.save(base_output_path, "PNG", quality=100)
    print(f"تم حفظ الصورة الأساسية: {base_output_path}")

    for size in sizes:
        if size == base_size:
            continue
        resized_img = img.resize((size, size), Image.LANCZOS)
        output_path = os.path.join(output_dir, f"app_icon_{size}x{size}.png")
        resized_img.save(output_path, "PNG", quality=100)
        print(f"تم حفظ الصورة بحجم {size}x{size}: {output_path}")

if __name__ == "__main__":
    input_image_path = "path/to/your/image.png"
    output_directory = "app_icons"
    prepare_app_icon(input_image_path, output_directory)
