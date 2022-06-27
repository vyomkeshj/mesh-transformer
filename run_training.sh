#!/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS=/home/jha0007/sac.json

# To convert the data to tfrecords and upload to bucket
python3 create_finetune_tfrecords.py ./data/sql_data/combined.txt "training_combined_2" --normalize-with-ftfy --n-repack-epochs 3 --seed 16 --verbose --output-dir gs://gpt-j-trainer-sql/data/
#python3 create_finetune_tfrecords.py ./data/sql_data/validation_wikisql.txt "validation_wikisql" --normalize-with-ftfy --output-dir gs://gpt-j-trainer-sql/data/

# To run training with a config and a previous saved model checkpoint
python3 ./device_train.py --config=./configs/combined_bsize2.json --tune-model-path=gs://gpt-j-trainer-sql/step_383500/

# To convert the model to pytorch weights for hugging face inference
#python3 ./to_hf_weights.py --input-ckpt gs://gpt-j-trainer-sql/sql_combined_16/step_3501 --config ./configs/combined_bsize8.json --output-path ./hf_sql_combined --cpu

# To convert the model to fp16 for tpu inference
python3 slim_model.py --config=./configs/combined_bsize2.json --ckpt-step=3501 --f16