#!/usr/bin/env python3

import os
# --- FORCE STABLE RENDERER ---
# This fixes the "Invisible images" issue on Arch/NVIDIA/Vulkan setups
os.environ["GSK_RENDERER"] = "cairo" 

import gi
import subprocess
import shutil
from concurrent.futures import ThreadPoolExecutor

gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, Gio, Gdk, GLib

# --- FIX PATH ---
home_dir = os.path.expanduser("~")
os.environ["PATH"] = f"{home_dir}/.local/bin:{home_dir}/.cargo/bin:{os.environ.get('PATH', '')}"

# --------- CONFIGURATION --------
WALLPAPER_DIR = os.path.expanduser("~/Pictures/wallpapers")
SYMLINK_PATH = os.path.expanduser("~/.config/hypr/current_wallpaper") 
# --------------------------------

class MyWindow(Gtk.ApplicationWindow):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.set_title("Wallpaper Selector")
        self.set_default_size(950, 600)

        # UI Setup
        self.main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_child(self.main_box)

        header_bar = Gtk.HeaderBar()
        self.set_titlebar(header_bar)

        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        self.main_box.append(scrolled)

        self.flowbox = Gtk.FlowBox()
        self.flowbox.set_valign(Gtk.Align.START)
        self.flowbox.set_max_children_per_line(5)
        self.flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
        self.flowbox.set_column_spacing(15)
        self.flowbox.set_row_spacing(15)
        
        for margin in ["start", "end", "top", "bottom"]:
            getattr(self.flowbox, f"set_margin_{margin}")(20)
        
        scrolled.set_child(self.flowbox)
        self.executor = ThreadPoolExecutor(max_workers=4)
        
        if os.path.exists(WALLPAPER_DIR):
            self.load_images()

    def load_images(self):
        images = [f for f in os.listdir(WALLPAPER_DIR) 
                  if f.lower().endswith(('.jpg', '.jpeg', '.png', '.webp'))]
        images.sort()
        
        for img_name in images:
            path = os.path.join(WALLPAPER_DIR, img_name)
            self.executor.submit(self.prepare_texture, path, img_name)

    def prepare_texture(self, path, name):
        try:
            # Gdk.Texture.new_from_file is the modern, non-deprecated way
            file_arg = Gio.File.new_for_path(path)
            texture = Gdk.Texture.new_from_file(file_arg)
            GLib.idle_add(self.add_to_ui, texture, name)
        except Exception as e:
            print(f"Failed to load {name}: {e}")

    def add_to_ui(self, texture, name):
        # Container
        item_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        
        # Image
        img_widget = Gtk.Image.new_from_paintable(texture)
        img_widget.set_pixel_size(250) # Force visible size
        img_widget.set_size_request(250, 140)
        img_widget.set_overflow(Gtk.Overflow.HIDDEN)
        
        # Label
        short_name = name if len(name) < 25 else name[:22] + "..."
        label = Gtk.Label(label=short_name)
        label.set_margin_top(5)
        
        item_box.append(img_widget)
        item_box.append(label)

        # Interaction
        click = Gtk.GestureClick()
        click.connect("released", self.on_click, name)
        item_box.add_controller(click)

        self.flowbox.append(item_box)
        return False

    def on_click(self, gesture, n_press, x, y, name):
        full_path = os.path.join(WALLPAPER_DIR, name)
        try:
            if os.path.exists(SYMLINK_PATH): os.remove(SYMLINK_PATH)
            os.makedirs(os.path.dirname(SYMLINK_PATH), exist_ok=True)
            os.symlink(full_path, SYMLINK_PATH)

            subprocess.run(["swww", "img", full_path, "--transition-type", "center"])
            subprocess.run(["matugen", "image", full_path])
            
            if shutil.which("pywal16"):
                subprocess.run(["pywal16", "-i", full_path, "-n"])
            
            subprocess.run("pkill -SIGUSR2 waybar || true", shell=True)
            subprocess.run(["notify-send", "-a", "Wallpaper Selector", "Theme Updated", name])
        except Exception as e:
            print(f"Error: {e}")
            
        self.close()

def on_activate(app):
    win = MyWindow(application=app)
    win.present()

if __name__ == "__main__":
    app = Gtk.Application(application_id='com.dikpal.wallpaperselector')
    app.connect("activate", on_activate)
    app.run(None)
