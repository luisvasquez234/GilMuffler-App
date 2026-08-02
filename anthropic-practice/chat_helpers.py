from dotenv import load_dotenv
load_dotenv()

from anthropic import Anthropic

client = Anthropic()
model = "claude-sonnet-5"


def add_user_message(messages, content):
    """`content` can be a plain string, or a list of content blocks
    (e.g. tool_result blocks, or a Message's `.content` for multi-block
    turns)."""
    user_message = {"role": "user", "content": content}
    messages.append(user_message)


def add_assistant_message(messages, content):
    """`content` can be a plain string, or a list of content blocks
    (e.g. a Message's `.content`, which may include thinking/tool_use
    blocks alongside text)."""
    assistant_message = {"role": "assistant", "content": content}
    messages.append(assistant_message)


def chat(messages, system=None, temperature=1.0, stop_sequences=[], output_config=None):
    params = {
        "model": model,
        "max_tokens": 4096,
        "messages": messages,
        "temperature": temperature,
        "thinking": {"type": "disabled"},
    }
    if system:
        params["system"] = system
    if stop_sequences:
        params["stop_sequences"] = stop_sequences
    if output_config:
        params["output_config"] = output_config

    response = client.messages.create(**params)
    for block in response.content:
        if block.type == "text":
            return block.text
    return ""
