#!/bin/bash
conda activate ml_exp
python3 device_train.py --config=./configs/wikisql.json --tune-model-path=gs://gpt-j-trainer-sql/step_383500/

python3 ./to_hf_weights.py --input-ckpt gs://gpt-j-trainer-sql/mesh_jax_pile_6B_rotary/step_104 --config ./configs/spider.json --output-path ./hf_sql_spider --cpu

gsutil cp -r ./hf_sql_spider/ gs://gpt-j-trainer-sql/hf_spider_sql/

