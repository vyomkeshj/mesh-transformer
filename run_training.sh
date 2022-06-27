#!/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS=/home/jha0007/sac.json

# To convert the data to tfrecords and upload to bucket
python3 create_finetune_tfrecords.py ./data/sql_data/combined.txt "training_combined_2" --normalize-with-ftfy --n-repack-epochs 3 --seed 16 --verbose --output-dir gs://gpt-j-trainer-sql/data/
#python3 create_finetune_tfrecords.py ./data/sql_data/validation_wikisql.txt "validation_wikisql" --normalize-with-ftfy --output-dir gs://gpt-j-trainer-sql/data/

# To run training with a config and a previous saved model checkpoint
python3 ./device_train.py --config=./configs/combined_bsize8.json --tune-model-path=gs://gpt-j-trainer-sql/step_383500/

# To convert the model to fp16 for tpu inference, select a saved version
python3 slim_model.py --config=./configs/combined_bsize8.json --ckpt-step=1438 --f16

# To convert the model to pytorch weights for hugging face inference
python3 ./to_hf_weights.py --input-ckpt gs://gpt-j-trainer-sql/sql_cleaned_slim_f16/step_1438 --config ./configs/combined_bsize8.json --output-path gs://gpt-j-trainer-sql/hf_cleaned_slim_f16/ --cpu
