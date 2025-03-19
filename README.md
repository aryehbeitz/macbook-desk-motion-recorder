# MacBook Desk Motion Recorder

A motion-activated recording system for macOS that uses the **Desk View Camera** for motion detection and the **Main Camera** for recording. The script intelligently detects movement and records **only when significant motion occurs**, reducing false positives.

## **Features**

✅ Uses the **Desk View Camera** for motion detection.

✅ Records **only when significant motion is detected**.

✅ Saves **trigger images alongside the video** so you can review what caused the recording.

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
chmod +x watch.sh record_video.sh
```

---

## **Usage**

### **Start the Motion Detector**

```sh
./watch.sh
```

The script will:

- Continuously monitor the **Desk View Camera** for motion.
- Trigger **recording using the Main Camera** when movement is detected.
- Save **trigger images and recorded videos** to `~/Desktop/security/`.

### **Stop the Motion Detector**

Press `Ctrl+C` in the terminal, or run:

```sh
pkill -f watch.sh
pkill -f record_video.sh
```

---

## **File Structure**

All recorded videos and trigger images are saved in `~/Desktop/security/`.

Example:

```
security/
├── .tmp/                    # Temporary files (automatically cleaned up)
│   ├── prev.jpg
│   ├── prev_2.jpg
│   ├── prev_3.jpg
│   └── curr.jpg
├── 2025_03_19_10_08_09-39_recording.mov
├── 2025_03_19_10_08_09_trigger_prev.jpg
└── 2025_03_19_10_08_09_trigger_curr.jpg
```

- `-39_recording.mov` → The recorded video (39 is the end second of the recording).

- `trigger_prev.jpg` → The image just before motion was detected.

- `trigger_curr.jpg` → The image when motion was detected.

- `.tmp/` → Directory containing temporary files used for motion detection. These files are automatically cleaned up when the script exits.

This ensures **videos and trigger images are ordered together** for easy review.

---

## **Author**

Developed by Aryeh.
Original implementation by [ChatGPT](https://openai.com/).
