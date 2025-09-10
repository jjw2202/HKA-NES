from PIL import Image


def value_to_hex_color(value):
    """Converts a value value to an HTML hex color value."""
    hex_value = f"{value:06x}"
    return tuple(int(hex_value[i:i+2], 16) for i in (0, 2, 4))  # RGB-Tupel


def load_colors_from_file(filename):
    """Loads hex or decimal values from a file and converts them to RGB colors."""
    colors = []
    with open(filename, 'r') as f:
        for row in f:
            s = row.strip()
            if not s:
                continue
            try:
                # Versuche zuerst, als Hex-String zu interpretieren
                if all(c in '0123456789abcdefABCDEF' for c in s) and (len(s) == 6 or len(s) == 3):
                    value = int(s, 16)
                else:
                    value = int(s)
                if 0 <= value <= 0xFFFFFF:
                    colors.append(value_to_hex_color(value))
            except ValueError:
                continue  # Ignore invalid rows
    return colors


def create_color_image(colors, width=24, height=8):
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
