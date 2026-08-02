from chat_helpers import add_assistant_message, add_user_message, client, model
from tools import get_current_datetime, get_current_datetime_schema

messages = []
add_user_message(messages, "What is the exact time, formatted as HH:MM:SS?")

response = client.messages.create(
    model=model,
    max_tokens=1000,
    messages=messages,
    tools=[get_current_datetime_schema],
)

add_assistant_message(messages, response.content)

if response.stop_reason == "tool_use":
    tool_use_block = next(b for b in response.content if b.type == "tool_use")
    result = get_current_datetime(**tool_use_block.input)
    tool_results = [{
        "type": "tool_result",
        "tool_use_id": tool_use_block.id,
        "content": result,
    }]

    add_user_message(messages, tool_results)

    response = client.messages.create(
        model=model,
        max_tokens=1000,
        messages=messages,
        tools=[get_current_datetime_schema],
    )

for block in response.content:
    if block.type == "text":
        print(block.text)
