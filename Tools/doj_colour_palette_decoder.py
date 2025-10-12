import tkinter as tk
from tkinter import ttk

# ------------------------------------------------------------------------------------------
# -- Dodonpachi Daioujou Colour Palette Decoder --
#
# Press F4 in MAME during gameplay to view the colour palettes
# Highlight a colour to see its 4-digit hex encoding
# This tool can convert the hex value to it's RGB 0-255 (non-hex) representation
# Can also enter RGB non-hex values and convert it to the encoding the game uses
# Useful for changing in-game colours
#-------------------------------------------------------------------------------------------

# --- Conversion functions ---
def decode_argb1555(value_hex):
    try:
        value = int(value_hex, 16) & 0xFFFF
    except ValueError:
        return None, "Invalid hex value."

    # Extract ARGB1555 bits
    a = (value >> 15) & 0x1
    r = (value >> 10) & 0x1F
    g = (value >> 5) & 0x1F
    b = value & 0x1F

    # Convert to 8-bit color
    a8 = 0xFF if a else 0x00
    r8 = int(round((r / 31) * 255))
    g8 = int(round((g / 31) * 255))
    b8 = int(round((b / 31) * 255))

    color_hex = f"#{r8:02X}{g8:02X}{b8:02X}"
    text = f"A: {a8}, R: {r8}, G: {g8}, B: {b8}\n#AARRGGBB: #{a8:02X}{r8:02X}{g8:02X}{b8:02X}"
    return color_hex, text

def encode_argb1555(r, g, b, a_flag=True):
    try:
        r = int(r)
        g = int(g)
        b = int(b)
    except ValueError:
        return None, "Invalid RGB values (must be integers 0–255)."

    if not all(0 <= x <= 255 for x in (r, g, b)):
        return None, "RGB values must be between 0–255."

    # Convert to 5-bit color (rounded)
    r5 = int(round((r / 255) * 31))
    g5 = int(round((g / 255) * 31))
    b5 = int(round((b / 255) * 31))

    # Clamp
    r5 = max(0, min(31, r5))
    g5 = max(0, min(31, g5))
    b5 = max(0, min(31, b5))

    a = 1 if a_flag else 0
    value = (a << 15) | (r5 << 10) | (g5 << 5) | b5

    color_hex = f"#{r:02X}{g:02X}{b:02X}"
    return color_hex, f"ARGB1555: {value:04X}"

# --- GUI actions ---
def on_hex_convert(event=None):
    hex_input = entry_hex.get().strip().upper()
    color, result = decode_argb1555(hex_input)
    output_hex.delete(1.0, tk.END)
    if result:
        output_hex.insert(tk.END, result)
    if color:
        color_preview_hex.config(bg=color)
    else:
        color_preview_hex.config(bg="#FFFFFF")

def on_rgb_convert(event=None):
    r = entry_r.get().strip()
    g = entry_g.get().strip()
    b = entry_b.get().strip()
    a_flag = alpha_var.get() == 1
    color, result = encode_argb1555(r, g, b, a_flag=a_flag)
    output_rgb.delete(1.0, tk.END)
    if result:
        output_rgb.insert(tk.END, result)
    if color:
        color_preview_rgb.config(bg=color)
    else:
        color_preview_rgb.config(bg="#FFFFFF")

# --- GUI setup ---
root = tk.Tk()
root.title("DOJ Colour Palette Decoder")
root.geometry("460x580")
root.resizable(False, False)

style = ttk.Style()
style.configure("TButton", font=("Segoe UI", 10))
style.configure("TLabel", font=("Segoe UI", 10))

main_frame = ttk.Frame(root, padding=15)
main_frame.pack(fill=tk.BOTH, expand=True)

# --- Section 1: HEX → ARGB ---
ttk.Label(main_frame, text="🔹 Convert 4-digit Hex → ARGB8888").pack(pady=(0,5))
entry_hex = ttk.Entry(main_frame, font=("Consolas", 12), width=10, justify="center")
entry_hex.pack(pady=5)
entry_hex.bind("<Return>", on_hex_convert)
ttk.Button(main_frame, text="Convert", command=on_hex_convert).pack(pady=5)
output_hex = tk.Text(main_frame, font=("Consolas", 11), height=4, width=50)
output_hex.pack(pady=(0,5))

# Color preview (for hex → ARGB)
ttk.Label(main_frame, text="Color Preview:").pack(pady=(0,2))
color_preview_hex = tk.Label(main_frame, bg="#FFFFFF", width=20, height=2, relief="solid", bd=1)
color_preview_hex.pack(pady=(0,15))

# --- Divider ---
ttk.Separator(main_frame, orient='horizontal').pack(fill='x', pady=10)

# --- Section 2: RGB → HEX ---
ttk.Label(main_frame, text="🔹 Convert RGB888 → 4-digit ARGB1555 Hex").pack(pady=(0,5))

rgb_frame = ttk.Frame(main_frame)
rgb_frame.pack(pady=5)

ttk.Label(rgb_frame, text="R:").grid(row=0, column=0, padx=2)
entry_r = ttk.Entry(rgb_frame, width=6, font=("Consolas", 11), justify="center")
entry_r.grid(row=0, column=1, padx=5)
ttk.Label(rgb_frame, text="G:").grid(row=0, column=2, padx=2)
entry_g = ttk.Entry(rgb_frame, width=6, font=("Consolas", 11), justify="center")
entry_g.grid(row=0, column=3, padx=5)
ttk.Label(rgb_frame, text="B:").grid(row=0, column=4, padx=2)
entry_b = ttk.Entry(rgb_frame, width=6, font=("Consolas", 11), justify="center")
entry_b.grid(row=0, column=5, padx=5)

# Alpha checkbox (default opaque)
alpha_var = tk.IntVar(value=1)
alpha_check = ttk.Checkbutton(main_frame, text="Opaque (alpha = 1)", variable=alpha_var)
alpha_check.pack(pady=(5,2))

ttk.Button(main_frame, text="Convert", command=on_rgb_convert).pack(pady=5)
output_rgb = tk.Text(main_frame, font=("Consolas", 11), height=2, width=50)
output_rgb.pack(pady=(0,5))

# Color preview (for RGB → Hex)
ttk.Label(main_frame, text="Color Preview:").pack(pady=(0,2))
color_preview_rgb = tk.Label(main_frame, bg="#FFFFFF", width=20, height=2, relief="solid", bd=1)
color_preview_rgb.pack(pady=(0,5))

# Enter key binding for RGB inputs
entry_r.bind("<Return>", on_rgb_convert)
entry_g.bind("<Return>", on_rgb_convert)
entry_b.bind("<Return>", on_rgb_convert)

root.mainloop()
