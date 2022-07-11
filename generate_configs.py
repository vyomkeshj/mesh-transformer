import sys
import json

args = sys.argv

config_name = args[0]
train_file = args[1]
val_file = args[2]
train_records = int(args[3])
val_records = int(args[4])
lr_start = int(args[5])
lr_end = int(args[6])
model_dir = args[7]

print(args)

if lr_start == "default":
    lr_start = 0.5e-5

if lr_end == "default":
    lr_end = 5e-7

if model_dir == "default":
    model_dir = "sql_wikisql_reformat"

gradient_accumulation_steps = 32
total_steps = train_records//gradient_accumulation_steps
warmup_steps = 0.1 * total_steps
anneal_steps = total_steps - warmup_steps
train_index_file_name = f"{train_file}_{train_records}.tfrecords"
val_index_file_name = f"{val_file}_{val_records}.tfrecords"
train_index_file = open(f"./data/{train_file}.validation.index", "w")
train_index_file.write(f"gs://gpt-j-trainer-sql/data/{train_index_file_name}")
train_index_file.close()
if val_file != "default":
    val_index_file = open(f"./data/{val_file}.validation.index", "w")
    val_index_file.write(f"gs://gpt-j-trainer-sql/data/{val_index_file_name}")
    val_index_file.close()
    pass

config = {
  "layers": 28,
  "d_model": 4096,
  "n_heads": 16,
  "n_vocab": 50400,
  "norm": "layernorm",
  "pe": "rotary",
  "pe_rotary_dims": 64,
  "seq": 2048,
  "cores_per_replica": 8,
  "per_replica_batch": 1,
  "gradient_accumulation_steps": gradient_accumulation_steps,
  "warmup_steps": warmup_steps,
  "anneal_steps": anneal_steps,
  "lr": lr_start,
  "end_lr": lr_end,
  "weight_decay": 0.1,
  "total_steps": total_steps,
  "tpu_size": 8,
  "bucket": "gpt-j-trainer-sql",
  "model_dir": model_dir,
  "train_set": train_index_file_name,
  "val_set": {
    "current": val_index_file_name
  },
  "eval_harness_tasks": [
    "lambada",
    "piqa",
    "hellaswag",
    "winogrande",
    "mathqa",
    "pubmedqa"
  ],
  "val_batches": 100,
  "val_every": 150,
  "ckpt_every": 1500,
  "keep_every": 3000,
  "name": "GPT3_6B_sql",
  "wandb_project": "sql_mesh",
  "comment": ""
}

with open(config_name, "w") as outfile:
    json.dump(config, outfile)