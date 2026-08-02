from dotenv import load_dotenv
load_dotenv()

from anthropic import Anthropic

client = Anthropic()
model = "claude-sonnet-5"

system_prompt = """
You are a patient tutor.
Do not directly answer a questions.
Guide them to a solution step by step.
"""


def add_user_message(messages, text):
    user_message = {"role": "user", "content": text}
    messages.append(user_message)


def add_assistant_message(messages, text):
    assistant_message = {"role": "assistant", "content": text}
    messages.append(assistant_message)


def chat(messages):
    message = client.messages.create(
        model=model,
        max_tokens=1000,
        messages=messages,
        system=system_prompt,
    )
    return message.content[0].text


messages = []

while True:
    user_input = input("You: ")
    if user_input.lower() in ("quit", "exit"):
        break

    add_user_message(messages, user_input)
    answer = chat(messages)
    add_assistant_message(messages, answer)
    print("Claude:", answer)
