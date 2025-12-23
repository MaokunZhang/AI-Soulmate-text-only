# AI Girlfriend Chatbot

A conversational AI girlfriend chatbot that uses OpenAI's GPT-3, MongoDB for conversation memory, and text-to-speech functionality.

## Features

- **Conversation Memory**: Stores and retrieves past conversations from MongoDB
- **Context-Aware Responses**: Uses conversation history to provide personalized responses
- **Text-to-Speech**: Speaks responses aloud using pyttsx3
- **Personality**: Sarcastic, clingy, and funny AI girlfriend persona

## Prerequisites

1. Python 3.8 or higher
2. MongoDB instance (local or cloud)
3. OpenAI API key

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Thomas-carpuncle/local-nsfw.git
   cd local-nsfw
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Set up environment variables:
   - Copy `.env.example` to `.env`
   - Add your OpenAI API key and MongoDB URI:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   MONGO_URI=mongodb://localhost:27017/
   ```

## Usage

Run the AI girlfriend chatbot:

```bash
python ai_girlfriend.py
```

Type your messages and the AI will respond. Type 'exit' to quit.

## How It Works

1. **fetch_memory(user_id, limit)**: Retrieves the last N conversations from MongoDB
2. **build_prompt(user_input, memory_docs)**: Creates a context-aware prompt using conversation history
3. **get_response(prompt)**: Calls OpenAI API to generate a response
4. **save_convo(user_input, ai_response, user_id)**: Saves the conversation to MongoDB
5. **speak(response)**: Converts the AI response to speech

## Database Structure

The chatbot stores conversations in MongoDB with the following structure:
- Database: `ai_girlfriend`
- Collection: `memories`
- Document fields:
  - `user_id`: Identifier for the user
  - `timestamp`: UTC timestamp of the conversation
  - `user_input`: User's message
  - `ai_response`: AI's response

## Configuration

You can customize:
- User ID (default: "mantra")
- Conversation memory limit (default: 5 messages)
- AI personality (edit the system prompt in `build_prompt()`)
- OpenAI parameters (temperature, max_tokens) in `get_response()`

## Dependencies

- `openai`: For GPT-3 API access
- `pymongo`: For MongoDB integration
- `python-dotenv`: For environment variable management
- `pyttsx3`: For text-to-speech functionality

## Security Notes

- Never commit your `.env` file to version control
- Keep your OpenAI API key secure
- Use appropriate MongoDB security settings in production
