from PIL import Image, ImageEnhance
import os

def prepare_app_icon(input_path, output_dir, base_size=1024, sizes=None):
    if sizes is None:
        sizes = [1024, 512, 256, 192, 180, 120, 96, 72, 48]

    # Create the output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Open and process the image
    try:
        img = Image.open(input_path).convert("RGBA")
    except Exception as e:
        print(f"Error opening image: {e}")
        return

    # Enhance contrast and color
    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(1.2)
    enhancer = ImageEnhance.Color(img)
    img = enhancer.enhance(1.1)

    # Resize to base size and save
    img = img.resize((base_size, base_size), Image.LANCZOS)
    base_output_path = os.path.join(output_dir, f"app_icon_{base_size}x{base_size}.png")
    img.save(base_output_path, "PNG", quality=100)
    print(f"Saved base image: {base_output_path}")

    # Generate other sizes
    for size in sizes:
        if size == base_size:
            continue
        resized_img = img.resize((size, size), Image.LANCZOS)
        output_path = os.path.join(output_dir, f"app_icon_{size}x{size}.png")
        resized_img.save(output_path, "PNG", quality=100)
        print(f"Saved image at size {size}x{size}: {output_path}")

def update_readme_with_icons():
    # Define the App Icons section
    app_icons_section = """
## 📱 App Icons

Below are the app icons for **PiMetaConnect** in various sizes, ready for use in different environments (e.g., app stores or devices):

| Size          | Icon                                                                   |
|---------------|------------------------------------------------------------------------|
| 48x48         | <img src="assets/icons/app_icon_48x48.png" alt="App Icon 48x48" width="48"/> |
| 72x72         | <img src="assets/icons/app_icon_72x72.png" alt="App Icon 72x72" width="72"/> |
| 96x96         | <img src="assets/icons/app_icon_96x96.png" alt="App Icon 96x96" width="96"/> |
| 120x120       | <img src="assets/icons/app_icon_120x120.png" alt="App Icon 120x120" width="120"/> |
| 180x180       | <img src="assets/icons/app_icon_180x180.png" alt="App Icon 180x180" width="180"/> |
| 192x192       | <img src="assets/icons/app_icon_192x192.png" alt="App Icon 192x192" width="192"/> |
| 256x256       | <img src="assets/icons/app_icon_256x256.png" alt="App Icon 256x256" width="256"/> |
| 512x512       | <img src="assets/icons/app_icon_512x512.png" alt="App Icon 512x512" width="512"/> |
| 1024x1024     | <img src="assets/icons/app_icon_1024x1024.png" alt="App Icon 1024x1024" width="512"/> |

---

"""

    # Read the existing README.md content
    if os.path.exists("README.md"):
        with open("README.md", "r", encoding="utf-8") as f:
            content = f.read()
    else:
        content = ""

    # Check if the App Icons section already exists
    if "## 📱 App Icons" in content:
        print("App Icons section already exists in README.md. Skipping update.")
        return

    # Append the App Icons section after the Features section
    if "## ✨ Features" in content:
        content = content.replace("## ✨ Features", "## ✨ Features\n\n" + app_icons_section)
    else:
        # If Features section doesn't exist, append at the end
        content += app_icons_section

    # Write the updated content back to README.md
    with open("README.md", "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated README.md with App Icons section.")

if __name__ == "__main__":
    # Use one of the existing icons as the input (e.g., app_icon_1024x1024.png)
    input_image_path = "app_icon_1024x1024.png"  # Adjust this path if needed
    output_directory = "assets/icons"
    
    # Prepare the app icons
    prepare_app_icon(input_image_path, output_directory)
    
    # Update README.md with the App Icons section
    update_readme_with_icons()
