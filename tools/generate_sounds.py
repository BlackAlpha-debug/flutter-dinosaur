"""Create original, short, low-amplitude PCM effects; no third-party assets."""
from pathlib import Path
import math
import struct
import wave

OUTPUT = Path(__file__).resolve().parents[1] / 'assets' / 'audio'
OUTPUT.mkdir(parents=True, exist_ok=True)

def sound(name, notes, seconds):
    rate = 22050
    frames = bytearray()
    for index in range(round(rate * seconds)):
        t = index / rate
        part = min(int(t / seconds * len(notes)), len(notes) - 1)
        phase = (t / seconds * len(notes)) % 1
        envelope = min(1, phase * 15) * (1 - phase) ** 2
        value = math.sin(2 * math.pi * notes[part] * t) * envelope * 0.18
        frames.extend(struct.pack('<h', int(value * 32767)))
    with wave.open(str(OUTPUT / f'{name}.wav'), 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(rate)
        out.writeframes(frames)

sound('jump', [440, 660], 0.15)
sound('star', [659.25, 880, 1046.5], 0.24)
sound('finish', [523.25, 659.25, 783.99], 0.4)
