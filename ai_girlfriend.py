import openai
import pymongo
import os
from dotenv import load_dotenv
from datetime import datetime
from text_to_voice import speak  # voice function from separate file

# Load environment variables
load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")
mongo_uri = os.getenv("MONGO_URI")

if not openai.api_key or not mongo_uri:
    raise ValueError("Missing OPENAI_API_KEY or MONGO_URI in environment.")

# Connect to MongoDB
client = pymongo.MongoClient(mongo_uri)
db = client["ai_girlfriend"]
collection = db["memories"]


def fetch_memory(user_id="mantra", limit=5):
    history = collection.find({"user_id": user_id}).sort("timestamp", -1).limit(limit)
    return list(history)


def build_prompt(user_input, memory_docs):
    context = "You are Mantra's sarcastic, clingy, funny AI girlfriend. You remember past conversations and moods.\n"
    for doc in reversed(memory_docs):
        context += f"Mantra: {doc['user_input']}\nGF: {doc['ai_response']}\n"
    context += f"Mantra: {user_input}\nGF:"
    return context


def get_response(prompt):
    response = openai.Completion.create(
        engine="text-davinci-003",
        prompt=prompt,
        temperature=0.8,
        max_tokens=100
    )
    return response.choices[0].text.strip()


def save_convo(user_input, ai_response, user_id="mantra"):
    collection.insert_one({
        "user_id": user_id,
        "timestamp": datetime.utcnow(),
        "user_input": user_input,
        "ai_response": ai_response
    })


def main():
    print("💬 Talk to your AI girlfriend! Type 'exit' to quit.\n")
    while True:
        user_input = input("You: ")
        if user_input.lower() == "exit":
            break

        memory = fetch_memory()
        prompt = build_prompt(user_input, memory)
        response = get_response(prompt)
        print("AI GF:", response)

        save_convo(user_input, response)
        speak(response)


if __name__ == "__main__":
    main()
