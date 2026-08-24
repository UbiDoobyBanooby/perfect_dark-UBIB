# Perfect Dark — UbiDooby Modern FPS Update + Rafccq External Texture Support

This is a ready-to-run build of the UbiDooby Modern FPS Update with Rafccq's external PNG texture support.

It does **not** include a Perfect Dark ROM or a texture pack. Use only files you are entitled to use.

## Start Here

1. Extract this download somewhere you can keep it.
2. Add your supported **NTSC Final** ROM, named exactly `pd.ntsc-final.z64`.
3. Start the game for your platform below.
4. Optional: install a texture pack, then enable **External Textures** in **Extended Options → Video** and restart the game.

## Windows and Linux

Put your ROM in the included `data` folder next to the game executable:

```text
UbiDooby-Modern-FPS-<platform>/
├── pd.x86_64.exe            (Windows)
├── pd.x86_64                (Linux)
└── data/
    ├── pd.ntsc-final.z64    ← your ROM
    └── ext_tex/             ← optional texture-pack files go here
```

Start the game by opening `pd.x86_64.exe` on Windows, or by running `./pd.x86_64` from a terminal in the extracted Linux folder.

## Apple-silicon Mac

Open `Perfect Dark.app`. On the first launch, choose your supported NTSC Final ROM when asked. The app copies it to the proper permanent location automatically.

If macOS blocks the app because it is from an unidentified developer, Control-click `Perfect Dark.app`, choose **Open**, then choose **Open** again. If necessary, use **System Settings → Privacy & Security → Open Anyway**.

The Mac app keeps game data outside the signed application bundle:

```text
~/Library/Application Support/perfectdark/data/
├── pd.ntsc-final.z64        ← copied here after first launch
└── ext_tex/                 ← optional texture-pack files go here
```

To open this location later in Finder, choose **Go → Go to Folder…** and enter:

```text
~/Library/Application Support/perfectdark/data
```

Do **not** add a ROM or texture files inside `Perfect Dark.app`. That changes the signed app and may cause macOS to reject it.

## Installing a Texture Pack

Most packs contain a folder named `ext_tex`. Its PNG files must sit directly inside the game's `ext_tex` folder:

```text
Correct:   data/ext_tex/0000.png
Incorrect: data/ext_tex/ext_tex/0000.png
```

Copy the **contents** of the pack's `ext_tex` folder into the game's existing `ext_tex` folder. Keep any font or model subfolders that come with the pack.

In the game, enable **External Textures** in **Extended Options → Video**, then restart Perfect Dark.

## Included Gameplay Options

**Movement:** ADS Move While Aiming, Modern Movement, and Weapon Wheel-Hold.

**Combat:** Live Target Reticle, Rapid Automatic Tap-Fire, and Modern ADS Combat.

Rapid Automatic Tap-Fire removes the limit on quick single shots from automatic weapons; full-auto fire is unchanged.

## Credits

The modern gameplay options are by UbiDoobyBanooby. External texture support is Rafccq's feature. This build is based on the Perfect Dark PC port and decompilation projects.
