#!/usr/bin/env python3

import gi
import os
import subprocess
import shutil
from concurrent.futures import ThreadPoolExecutor
from gi.repository import Gtk, Gio, Gdk, GdkPixbuf, GLib

gi.require_version("Gtk", "4.0")

# --- FIX PATH FOR KEYBINDINGS ---
home_dir = os.path.expanduser("~")
new_path = (
    f"{home_dir}/.local/bin:"
    f"{home_dir}/.cargo/bin:"
    f"{os.environ.get('PATH', '')}"
)
os.environ["PATH"] = new_path
# --------------------------------

# --------- CONFIGURATION --------
WALLPAPER_DIR = os.path.expanduser("~/Pictures/wallpapers")
# Where the symlink will be created (Same as your friend's config)
SYMLINK_PATH = os.path.expanduser("~/.config/hypr/current_wallpaper") 
# --------------------------------

class MyWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Wallpaper Selector")
        self.set_default_size(900, 600)
        self.connect("destroy", self.on_destroy)

        # Create a HeaderBar
        header_bar = Gtk.HeaderBar.new()
        header_bar.set_title_widget(Gtk.Label(label="Select Wallpaper"))
        self.set_titlebar(header_bar)

        # Create ScrolledWindow
        scrolled_window = Gtk.ScrolledWindow()
        self.set_child(scrolled_window)

        # Create FlowBox
        self.flowbox = Gtk.FlowBox()
        self.flowbox.set_valign(Gtk.Align.START)
        self.flowbox.set_max_children_per_line(5)
        self.flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
        scrolled_window.set_child(self.flowbox)

        # Async Loader
        self.executor = ThreadPoolExecutor(max_workers=4)
        if os.path.exists(WALLPAPER_DIR):
            self.load_thumbnails_async(WALLPAPER_DIR)
        else:
            print(f"Error: Directory {WALLPAPER_DIR} not found.")

    def on_destroy(self, window):
        app = self.get_application()
        if app:
            app.quit()

    def load_thumbnails_async(self, folder_path):
        images = [f for f in os.listdir(folder_path) if f.lower().endswith(('.jpg', '.jpeg', '.png', '.webp'))]
        images.sort() # Sort alphabetically
        
        thumbnail_width = 250
        thumbnail_height = 140

        for image in images:
            self.executor.submit(self.create_thumbnail_and_add_to_flowbox,
                                 folder_path, image, thumbnail_width, thumbnail_height)

    def create_thumbnail_and_add_to_flowbox(self, folder_path, image_name, width, height):
        try:
            image_path = os.path.join(folder_path, image_name)
            thumbnail = self.create_thumbnail(image_path, width, height)
            GLib.idle_add(self.add_image_to_flowbox, thumbnail, image_name, width, height)
        except Exception as e:
            print(f"Error loading image {image_name}: {e}")

    def add_image_to_flowbox(self, thumbnail, image_name, width, height):
        image_widget = Gtk.Picture.new_for_pixbuf(thumbnail)
        image_widget.set_size_request(width, height)
        
        # Add margins for spacing
        image_widget.set_margin_start(10)
        image_widget.set_margin_end(10)
        image_widget.set_margin_top(10)
        image_widget.set_margin_bottom(10)

        # Click Gesture
        click_gesture = Gtk.GestureClick.new()
        click_gesture.connect("pressed", self.on_thumbnail_click, image_name)
        image_widget.add_controller(click_gesture)

        self.flowbox.insert(image_widget, -1)

    def on_thumbnail_click(self, gesture, n_press, x, y, image_name):
        full_path = os.path.join(WALLPAPER_DIR, image_name)
        print(f":: Applying: {image_name}")

        try:
            # --- 0. Update Symlink (New Addition) ---
            # Mimics 'ln -sf': Remove existing link if present, then create new one
            if os.path.islink(SYMLINK_PATH) or os.path.exists(SYMLINK_PATH):
                os.remove(SYMLINK_PATH)
            
            # Create the parent directory if it doesn't exist yet
            os.makedirs(os.path.dirname(SYMLINK_PATH), exist_ok=True)
            
            os.symlink(full_path, SYMLINK_PATH)
            print(f":: Symlink updated: {SYMLINK_PATH} -> {full_path}")
            # ----------------------------------------

            # 1. SWWW (Set Wallpaper)
            subprocess.run(["swww", "img", full_path, 
                           "--transition-type", "center", 
                           "--transition-step", "90", 
                           "--transition-fps", "60"])

            # 2. Matugen (Generate Colors for Niri, GTK, etc.)
            subprocess.run(["matugen", "image", full_path])

            # 3. Pywal16 (Generate Colors for Terminals)
            if shutil.which("pywal16"):
                subprocess.run(["pywal16", "-i", full_path, "-n"])
            elif shutil.which("wal"):
                subprocess.run(["wal", "-i", full_path, "-n"])

            # 4. Waybar (Reload CSS)
            subprocess.run("pkill -SIGUSR2 waybar || true", shell=True)

            # 5. Notify
            subprocess.run(["notify-send", "-a", "Wallpaper Selector", 
                           "-i", full_path, 
                           "Theme Updated", f"Applied {image_name}"])

        except Exception as e:
            print(f"Error executing commands: {e}")

        self.close()

    def create_thumbnail(self, image_path, width, height):
        pixbuf = GdkPixbuf.Pixbuf.new_from_file(image_path)
        
        # Scale logic to fill/crop nicely
        pix_w = pixbuf.get_width()
        pix_h = pixbuf.get_height()
        ratio = max(width / pix_w, height / pix_h)
        
        new_w = int(pix_w * ratio)
        new_h = int(pix_h * ratio)
        
        scaled_pixbuf = pixbuf.scale_simple(new_w, new_h, GdkPixbuf.InterpType.BILINEAR)

        # Center crop
        final_pixbuf = GdkPixbuf.Pixbuf.new(GdkPixbuf.Colorspace.RGB, True, 8, width, height)
        final_pixbuf.fill(0x00000000)
        
        offset_x = (width - new_w) // 2
        offset_y = (height - new_h) // 2
        
        scaled_pixbuf.composite(final_pixbuf, 0, 0, width, height,
                                offset_x, offset_y, 1.0, 1.0, 
                                GdkPixbuf.InterpType.BILINEAR, 255)
        return final_pixbuf


def main():
    app = Gtk.Application(application_id='com.dikpal.wallpaperselector')
    app.connect("activate", on_activate)
    app.run(None)


def on_activate(app):
    win = MyWindow()
    win.set_application(app)
    win.present()


if __name__ == "__main__":
    main()
