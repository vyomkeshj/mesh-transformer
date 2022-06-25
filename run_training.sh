#!/bin/bash
conda activate ml_exp
export GOOGLE_APPLICATION_CREDENTIALS="/home/jha0007/sac.json”
cd mesh_transformer
python3 create_finetune_tfrecords.py ./data/sql_data/train_wikisql.txt "training_wikisql" --normalize-with-ftfy --n-repack-epochs 6 --output-dir gs://gpt-j-trainer-sql/data/
python3 create_finetune_tfrecords.py ./data/sql_data/validation_wikisql.txt "validation_wikisql" --normalize-with-ftfy --output-dir gs://gpt-j-trainer-sql/data/
python3 device_train.py --config=./configs/wikisql.json --tune-model-path=gs://gpt-j-trainer-sql/step_383500/

#python3 ./to_hf_weights.py --input-ckpt gs://gpt-j-trainer-sql/mesh_jax_pile_6B_rotary/step_104 --config ./configs/spider.json --output-path ./hf_sql_spider --cpu

