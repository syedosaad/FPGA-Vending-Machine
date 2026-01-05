from PIL import Image

def convert_image_to_mif(image_path, output_file, width, height):
    """
    Converts an image to a .mif file for FPGA memory initialization.

    :param image_path: Path to the input image (e.g., PNG or JPEG file).
    :param output_file: Name of the output .mif file.
    :param width: Width of the image in pixels.
    :param height: Height of the image in pixels.
    """
    # Open and resize the image
    img = Image.open(image_path).convert("RGB")
    img = img.resize((width, height))  # Resize to desired dimensions

    # Create a list to store pixel data in RGB565 format
    rgb565_data = []

    for y in range(img.height):
        for x in range(img.width):
            r, g, b = img.getpixel((x, y))
            # Convert RGB888 to RGB565
            rgb565 = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)
            rgb565_data.append(rgb565)

    # Write the data to a .mif file
    with open(output_file, "w") as mif:
        # Write the MIF header
        mif.write(f"DEPTH = {width * height};\n")
        mif.write("WIDTH = 16;\n")
        mif.write("ADDRESS_RADIX = HEX;\n")
        mif.write("DATA_RADIX = HEX;\n")
        mif.write("CONTENT\nBEGIN\n")

        # Write pixel data
        for address, value in enumerate(rgb565_data):
            mif.write(f"{address:04X} : {value:04X};\n")

        # End of MIF file
        mif.write("END;\n")

    print(f".mif file successfully created: {output_file}")

# Example usage
if __name__ == "__main__":
    # Input image and output MIF file
    input_image = "monster.jpg"  # Replace with your image file
    output_mif = "slade.mif"   # Desired output .mif file
    image_width = 240          # Width of the image
    image_height = 320         # Height of the image

    # Convert the image to a .mif file
    convert_image_to_mif(input_image, output_mif, image_width, image_height)