"""
Text to voice module for AI girlfriend chatbot.
Provides text-to-speech functionality using pyttsx3.
"""

import pyttsx3


def speak(text):
    """
    Convert text to speech and play it.

    Args:
        text (str): The text to be spoken
    """
    try:
        engine = pyttsx3.init()
        engine.say(text)
        engine.runAndWait()
    except Exception as e:
        print(f"Warning: Could not speak text due to error: {e}")
        # Fail silently if TTS is not available
