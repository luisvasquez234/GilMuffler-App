import json

from chat_helpers import add_user_message, chat

GRADE_SCHEMA = {
    "type": "object",
    "properties": {
        "reasoning": {"type": "string"},
        "score": {"type": "integer"},
    },
    "required": ["reasoning", "score"],
    "additionalProperties": False,
}


def run_prompt(test_case):
    """Merges the prompt and test case input, then returns the result"""
    prompt = f"""
Please solve the following task:

{test_case["task"]}

Before responding, double-check any example output you include (sample
inputs/outputs, walkthroughs) to make sure it's accurate and consistent with
the actual code, regex, or JSON you provide. Fix any mismatch before
answering.
"""

    messages = []
    add_user_message(messages, prompt)
    output = chat(messages)
    return output


def grade_by_model(test_case, output):
    """Uses Claude as a judge to score how well `output` solves `test_case`"""
    grading_prompt = f"""
You are an expert code reviewer evaluating an AI's response to a technical task.

Task given to the AI:
{test_case["task"]}

AI's response:
{output}

Grade the response on a scale of 1-10 based on:
- Correctness: does the Python function, regex, or JSON actually solve the task?
- Completeness: does it fully address what was asked?
- Quality: is it well-structured and usable as-is, without needing fixes?

A 10 means the response is fully correct and ready to use. A 1 means it does
not solve the task at all.
"""
    messages = []
    add_user_message(messages, grading_prompt)
    grade_response = chat(
        messages,
        output_config={"format": {"type": "json_schema", "schema": GRADE_SCHEMA}},
    )
    return json.loads(grade_response)


def run_test_case(test_case):
    """Calls run_prompt, then grades the result"""
    output = run_prompt(test_case)
    grade = grade_by_model(test_case, output)

    return {
        "output": output,
        "test_case": test_case,
        "score": grade["score"],
        "reasoning": grade["reasoning"],
    }


def run_eval(dataset):
    """Loads the dataset and calls run_test_case with each case"""
    results = []

    for test_case in dataset:
        result = run_test_case(test_case)
        results.append(result)

    return results


if __name__ == "__main__":
    with open("dataset.json") as f:
        dataset = json.load(f)

    results = run_eval(dataset)
    for result in results:
        print("Task:", result["test_case"]["task"])
        print("Score:", result["score"])
        print("Reasoning:", result["reasoning"])
        print()
