import ast
import json
import re
from statistics import mean

from chat_helpers import add_user_message, chat


def validate_json(text):
    try:
        json.loads(text.strip())
        return 10
    except json.JSONDecodeError:
        return 0


def validate_python(text):
    try:
        ast.parse(text.strip())
        return 10
    except SyntaxError:
        return 0


def validate_regex(text):
    try:
        re.compile(text.strip())
        return 10
    except re.error:
        return 0


def extract_code_block(output, lang=None):
    """Pulls a fenced code block out of a markdown response.

    Prefers a block tagged with `lang` (e.g. a response often shows an
    illustrative snippet before the real ```python/```json/```regex answer),
    falling back to the first fenced block of any kind.
    """
    if lang:
        match = re.search(rf"```{lang}\n(.*?)```", output, re.DOTALL)
        if match:
            return match.group(1)
    match = re.search(r"```(?:\w+)?\n(.*?)```", output, re.DOTALL)
    if match:
        return match.group(1)
    return output


VALIDATORS = {
    "python": validate_python,
    "json": validate_json,
    "regex": validate_regex,
}


def grade_syntax(output, test_case):
    """Runs the validator for the task's declared format against its code block"""
    fmt = test_case["format"]
    validator = VALIDATORS[fmt]
    return validator(extract_code_block(output, fmt))


GRADE_SCHEMA = {
    "type": "object",
    "properties": {
        "strengths": {"type": "array", "items": {"type": "string"}},
        "weaknesses": {"type": "array", "items": {"type": "string"}},
        "reasoning": {"type": "string"},
        "score": {"type": "integer"},
    },
    "required": ["strengths", "weaknesses", "reasoning", "score"],
    "additionalProperties": False,
}


def run_prompt(test_case):
    """Merges the prompt and test case input, then returns the result"""
    prompt = f"""
Please solve the following task:

{test_case["task"]}

* Respond only with Python, JSON, or a plain Regex
* Do not add any comments or commentary or explanation
"""

    messages = []
    add_user_message(messages, prompt)
    output = chat(messages)
    return output


def grade_by_model(test_case, output):
    """Uses Claude as a judge to score how well `output` solves `test_case`"""
    eval_prompt = f"""
You are an expert code reviewer. Evaluate this AI-generated solution.

Task: {test_case["task"]}
Solution: {output}

Judge it on:
- Correctness: does the Python function, regex, or JSON actually solve the task?
- Completeness: does it fully address what was asked?
- Quality: is it well-structured and usable as-is, without needing fixes?

Provide your evaluation with:
- "strengths": an array of 1-3 key strengths
- "weaknesses": an array of 1-3 key areas for improvement
- "reasoning": a concise explanation of your assessment
- "score": a number between 1-10, where 10 means fully correct and ready to
  use, and 1 means it does not solve the task at all
"""
    messages = []
    add_user_message(messages, eval_prompt)
    eval_text = chat(
        messages,
        output_config={"format": {"type": "json_schema", "schema": GRADE_SCHEMA}},
    )
    return json.loads(eval_text)


def run_test_case(test_case):
    output = run_prompt(test_case)

    model_grade = grade_by_model(test_case, output)
    model_score = model_grade["score"]
    syntax_score = grade_syntax(output, test_case)

    score = (model_score + syntax_score) / 2

    return {
        "output": output,
        "test_case": test_case,
        "score": score,
        "model_score": model_score,
        "syntax_score": syntax_score,
        "reasoning": model_grade["reasoning"],
    }


def run_eval(dataset):
    results = []

    for test_case in dataset:
        result = run_test_case(test_case)
        results.append(result)

    average_score = mean([result["score"] for result in results])
    print(f"Average score: {average_score}")

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
