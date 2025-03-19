# MacBook Desk Motion Recorder

A motion-activated recording system for macOS that uses the **Desk View Camera** for motion detection and the **Main Camera** for recording. The script intelligently detects movement and records **only when significant motion occurs**, reducing false positives.

## **Features**

✅ Uses the **Desk View Camera** for motion detection.

✅ Records **only when significant motion is detected**.

✅ Shows **real-time motion detection** with side-by-side preview, current, and difference views.

✅ **Highlights changes in red** to easily spot what triggered the recording.

✅ **Pauses detection during recording** and **resumes 10 seconds after recording stops**.

✅ **Suppresses false positives** by filtering minor lighting or noise variations.

✅ **Fully automated and runs in the background**.

---

## **Installation**

### **1. Install Dependencies**

```sh
brew install ffmpeg imagemagick bc
```

### **2. Clone This Repository**

```sh
git clone https://github.com/YOUR_USERNAME/macbook-desk-motion-recorder.git
cd macbook-desk-motion-recorder
```

### **3. Make Scripts Executable**

```sh
chmod +x watch.sh record_video.sh clean.sh
```

---

## **Usage**

### **Start the Motion Detector**

```sh
./watch.sh
```

The script will:

- Continuously monitor the **Desk View Camera** for motion.
- Show real-time preview of:
  - Previous frame
  - Current frame
  - Difference visualization (changes highlighted in red)
- Trigger **recording using the Main Camera** when movement is detected.
- Save **recorded videos and difference images** to `~/Desktop/security/`.

### **Stop the Motion Detector**

Press `Ctrl+C` in the terminal, or run:

```sh
pkill -f watch.sh
pkill -f record_video.sh
```

### **Clean Recordings**

To remove all recordings and difference images:

```sh
./clean.sh
```

This will:

- Show how many recordings will be deleted
- Ask for confirmation before proceeding
- Clean all recordings while preserving the directory structure
- Clean temporary files in the `.tmp` directory

---

## **File Structure**

All recorded videos and difference images are saved in `~/Desktop/security/`.

Example:

```
security/
├── .tmp/                    # Temporary files (automatically cleaned up)
│   ├── prev.jpg
│   ├── prev_2.jpg
│   ├── prev_3.jpg
│   └── curr.jpg
├── 2025_03_19_10_08_09-39_recording.mov
└── 2025_03_19_10_08_09_diff.jpg
```

- `-39_recording.mov` → The recorded video (39 is the end second of the recording).

- `diff.jpg` → A visual representation of what changed between frames, with changes highlighted in red.

- `.tmp/` → Directory containing temporary files used for motion detection. These files are automatically cleaned up when the script exits.

This ensures **videos and difference images are ordered together** for easy review.

---

## **Terminal Support**

The script supports real-time image display in:

- **Kitty Terminal** - Full image support
- **iTerm2** - Full image support
- **Other terminals** - Falls back to ASCII art representation

For the best experience, use Kitty Terminal or iTerm2.

---

## **Author**

Developed by Aryeh.
Original implementation by [ChatGPT](https://openai.com/).
