import json

from chat_helpers import add_user_message, chat

DATASET_SCHEMA = {
    "type": "object",
    "properties": {
        "tasks": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "task": {"type": "string"},
                    "format": {"type": "string", "enum": ["python", "json", "regex"]},
                },
                "required": ["task", "format"],
                "additionalProperties": False,
            },
        }
    },
    "required": ["tasks"],
    "additionalProperties": False,
}


def generate_dataset():
    prompt = """
Generate an evaluation dataset for a prompt evaluation. The dataset will be used to evaluate prompts that generate Python, JSON, or Regex specifically for AWS-related tasks. Generate an array of tasks, each representing a task that requires Python, JSON, or a Regex to complete.

* Focus on tasks that can be solved by writing a single Python function, a single JSON object, or a single regex
* Focus on tasks that do not require writing much code
* For each task, set "format" to whichever of "python", "json", or "regex" the solution should be written in

Please generate 3 tasks.
"""
    messages = []
    add_user_message(messages, prompt)
    text = chat(
        messages,
        output_config={"format": {"type": "json_schema", "schema": DATASET_SCHEMA}},
    )
    return json.loads(text)["tasks"]


if __name__ == "__main__":
    dataset = generate_dataset()
    with open("dataset.json", "w") as f:
        json.dump(dataset, f, indent=2)
    print(f"Saved {len(dataset)} tasks to dataset.json")
