import json
from statistics import mean

from chat_helpers import add_user_message, chat

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


def generate_dataset(task_description, prompt_inputs_spec, output_file=None, num_cases=3):
    """Generates a dataset of realistic test cases for a given task.

    `prompt_inputs_spec` maps each input variable name to a short description
    of what it represents. Each generated case is a dict with one value per
    variable, e.g. {"height": "...", "weight": "...", ...}.
    """
    fields_description = "\n".join(
        f"- {name}: {description}" for name, description in prompt_inputs_spec.items()
    )

    schema = {
        "type": "object",
        "properties": {
            "cases": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        name: {"type": "string"} for name in prompt_inputs_spec
                    },
                    "required": list(prompt_inputs_spec.keys()),
                    "additionalProperties": False,
                },
            }
        },
        "required": ["cases"],
        "additionalProperties": False,
    }

    prompt = f"""
Generate an evaluation dataset for the following task:

{task_description}

Each test case should provide realistic, varied values for these inputs:
{fields_description}

Generate {num_cases} distinct, realistic test cases.
"""

    messages = []
    add_user_message(messages, prompt)
    text = chat(
        messages,
        output_config={"format": {"type": "json_schema", "schema": schema}},
    )
    dataset = json.loads(text)["cases"]

    if output_file:
        with open(output_file, "w") as f:
            json.dump(dataset, f, indent=2)

    return dataset


def run_prompt(prompt_inputs):
    prompt = f"""
Write a compact, concise 1 day meal plan for this athlete:

- Height: {prompt_inputs["height"]}
- Weight: {prompt_inputs["weight"]}
- Goal: {prompt_inputs["goal"]}
- Dietary restrictions: {prompt_inputs["restrictions"]}
"""

    messages = []
    add_user_message(messages, prompt)
    return chat(messages)


def grade_by_model(task_description, test_case, output):
    """Uses Claude as a judge to score how well `output` solves `test_case`"""
    eval_prompt = f"""
You are an expert evaluator. Evaluate this AI-generated response.

Task: {task_description}
Input: {json.dumps(test_case)}
Response: {output}

Judge it on:
- Correctness: does the response actually satisfy the task given the input?
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


def run_test_case(task_description, test_case):
    """Runs one test case through the prompt, then grades the result"""
    output = run_prompt(test_case)
    grade = grade_by_model(task_description, test_case, output)

    return {
        "output": output,
        "test_case": test_case,
        "score": grade["score"],
        "reasoning": grade["reasoning"],
        "strengths": grade["strengths"],
        "weaknesses": grade["weaknesses"],
    }


def run_eval(task_description, dataset):
    """Runs every case in the dataset through the prompt and prints the average score"""
    results = [run_test_case(task_description, test_case) for test_case in dataset]

    average_score = mean(result["score"] for result in results)
    print(f"Average score: {average_score}")

    return results


if __name__ == "__main__":
    TASK_DESCRIPTION = "Write a compact, concise 1 day meal plan for a single athlete"

    dataset = generate_dataset(
        task_description=TASK_DESCRIPTION,
        prompt_inputs_spec={
            "height": "Athlete's height in cm",
            "weight": "Athlete's weight in kg",
            "goal": "Goal of the athlete",
            "restrictions": "Dietary restrictions of the athlete",
        },
        output_file="dataset.json",
        num_cases=3,
    )

    results = run_eval(TASK_DESCRIPTION, dataset)
    for result in results:
        print()
        print("Input:", result["test_case"])
        print("Score:", result["score"])
        print("Reasoning:", result["reasoning"])
