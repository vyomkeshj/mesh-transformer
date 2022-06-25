
import torch
import os
import pandas as pd
import numpy as np

os.environ["WANDB_DISABLED"] = "true"
from transformers import AutoTokenizer, GPTJForCausalLM

# torch.backends.cuda.matmul.allow_tf32 = True
cache = "./cache"

torch.manual_seed(42)
tokenizer = AutoTokenizer.from_pretrained("EleutherAI/gpt-j-6B", cache_dir=cache)
tokenizer.pad_token = tokenizer.eos_token

model = GPTJForCausalLM.from_pretrained("./wikisql_1", local_files_only=True).cpu()


def ask_client(query, max_length=100):
    input = f"""Take the database columns in the [Schema Json] section, question in [Question] section and generate SQL for the question on the schema.
    [Schema Json]: "insurance_data":[insured_hobbies, incident_severity, 
    authorities_contacted, incident_hour_of_the_day, number_of_vehicles_involved, 
    property_damage, bodily_injuries, witnesses, police_report_available, total_claim_amount, injury_claim, property_claim, 
    vehicle_claim, vehicle_manufacturer, auto_model,auto_year, fraud_reported] [Question]: {query} [SQL]: """
    print(input + "\n \n")
    tokens = tokenizer(input, return_tensors="pt").input_ids.cpu()

    # for temperature_now in np.arange(0.1, 2.0, 0.1):
    sample_outputs = model.generate(tokens,
                                    do_sample=True,
                                    early_stopping=True,
                                    top_k=50,
                                    max_length=350,
                                    num_beams=5,
                                    top_p=0.95,
                                    temperature=0.9,
                                    num_return_sequences=1)
    for i, sample_output in enumerate(sample_outputs):
        current_output = tokenizer.decode(sample_output, skip_special_tokens=True)
        output = tokenizer.decode(sample_outputs[0], skip_special_tokens=True)
        before, sep, after = output.partition('SELECT')
        query = sep + after
        print("{}: {}\n".format(i, query))

    output = tokenizer.decode(sample_outputs[0], skip_special_tokens=True)
    before, sep, after = output.partition('SELECT')
    query = sep + after
    print("Query: " + query + '\n')
    return "None"

your_question = "How many people are over 43 and have a Saab?"
question_2="Show me the insured customers with who live in the zip 466132"
ask_client(your_question)
