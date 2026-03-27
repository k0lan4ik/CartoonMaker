<h1 align="center">
  🎬 CartoonMaker
</h1>

<p align="center">
  <b>A desktop 2D animation editor — place characters on a scene, set keyframes and watch them come to life.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/language-Delphi%20(Object%20Pascal)-EE1F35?style=for-the-badge&logo=delphi&logoColor=white" />
  <img src="https://img.shields.io/badge/framework-VCL-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white" />
  <img src="https://img.shields.io/badge/format-.AFC-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/status-in%20development-yellow?style=for-the-badge" />
</p>

---

## 📖 About

**CartoonMaker** is a Windows desktop application for creating simple 2D animations.
You load sprite-based characters, place them on a scene, record their movement using keyframes on a timeline, and play the result back in real time.

Animations are saved in a custom binary format `.AFC` and can also be exported as GIF.

---

## ✨ Features

- 🖼️ **PNG sprite support** — load animated characters from folders (frame strips)
- 🎭 **Scene editor** — place, drag and scale objects on a 1920×1080 canvas
- 🔑 **Keyframe animation** — record object movement with start/end points and timing
- ⏱️ **Custom Timeline** — visual timeline with time ruler, scrolling and zoom
- ▶️ **Playback** — real-time animation preview with play/pause
- 🔄 **Mirror support** — flip characters horizontally per keyframe
- 💾 **Save / Load** — custom `.AFC` binary format for scenes
- 🎞️ **GIF export** — export your animation as an animated GIF
- 🔍 **Scene zoom & pan** — mouse wheel zoom and middle-click pan

---

## 🏗️ Architecture

| Module | Description |
|---|---|
| `Main` | Main form — scene rendering, mouse interaction, playback loop |
| `LoadManager` | Loads PNG sprite resources from the `Animation/` folder |
| `SceneManager` | Manages scene objects, keyframe linked lists, save/load to `.AFC` |
| `TimeLine` | Custom VCL component — timeline with ruler, keyframe blocks, scrollbars |
| `DialogAddFrame` | Dialog for configuring a new keyframe (duration, animation, mirror) |
| `CustomSpinEdit` | Extended float spin-edit control |
| `FileWork` | File open/save helpers for `.AFC` and GIF formats |

---

## 📁 Project Structure

```
CartoonMaker/
│
├── Main.pas / .dfm         # Main form — scene, toolbar, splitters
├── LoadManager.pas         # Sprite loader (reads PNG folders)
├── SceneManager.pas        # Scene objects and keyframe management
├── TimeLine.pas            # Custom Timeline VCL component
├── DialogAddFrame.pas      # Add keyframe dialog
├── CustomSpinEdit.pas      # Float SpinEdit component
├── FileWork.pas            # File I/O helpers
│
└── Animation/              # Sprite resources folder
    └── CharacterName/
        ├── main.png        # Preview / idle frame
        ├── idle.png        # Idle animation strip
        └── walk.png        # Other animation strips
```

---

## 🚀 Getting Started

### Requirements

- [Delphi](https://www.embarcadero.com/products/delphi) (RAD Studio) — any version supporting VCL
- Windows OS

### Build & Run

1. Open the project in Delphi IDE
2. Make sure the `Animation/` folder with sprite resources is next to the executable
3. Press **F9** to compile and run

### Using the editor

1. Place sprite folders in the `Animation/` directory — each folder is one character
2. Select a character from the **Loaded** panel on the left
3. **Left-click** on the scene to place the character
4. Select the character, press **Add Keyframe** and drag it to a new position
5. Press **▶ Play** to preview the animation
6. Save your scene via **File → Save** (`.AFC` format)

---

## 🛠️ Tech Stack

| | |
|---|---|
| **Language** | Object Pascal (Delphi) |
| **UI Framework** | VCL (Visual Component Library) |
| **Graphics** | `TPngImage`, `TBitmap`, GDI |
| **Platform** | Windows (Win32/Win64) |
| **Scene format** | Custom binary `.AFC` |
| **Export** | GIF animation |

---

## 📜 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️, Delphi and a timeline full of keyframes.
</p>
