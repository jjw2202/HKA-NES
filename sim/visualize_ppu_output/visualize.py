from PIL import Image


def decimal_to_hex_color(dec_value):
    """Converts a decimal value to an HTML hex color value."""
    hex_value = f"{dec_value:06x}"
    return tuple(int(hex_value[i:i+2], 16) for i in (0, 2, 4))  # RGB-Tupel


def load_colors_from_file(filename):
    """Loads decimal values from a file and converts them to RGB colors."""
    colors = []
    with open(filename, 'r') as f:
        for row in f:
            try:
                dec_value = int(row.strip())
                if 0 <= dec_value <= 0xFFFFFF:
                    colors.append(decimal_to_hex_color(dec_value))
            except ValueError:
                continue  # Ignore invalid rows
    return colors


def create_color_image(colors, width=256, height=240):
    """Creates an image from a list of RGB colors."""
    picture = Image.new("RGB", (width, height))
    pixel = picture.load()

    for y in range(height):
        for x in range(width):
            index = y * width + x
            if index < len(colors):
                pixel[x, y] = colors[index]
            else:
                # Fill with black if there are too few colors
                pixel[x, y] = (0, 0, 0)

    return picture


if __name__ == "__main__":
    colors = load_colors_from_file("PPUoutput.txt")
    picture = create_color_image(colors)
    picture.save("PPUoutput.png")
    print("Image successfully saved as 'PPUoutput.png'")
