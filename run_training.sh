#!/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS=/home/jha0007/sac.json
CONFIG_FILE="./configs/combined_bsize8.json"

# To convert the data to tfrecords and upload to bucket
#python3 create_finetune_tfrecords.py ./data/sql_data/spider_reformat.txt "spider_reformat" --normalize-with-ftfy --n-repack-epochs 1 --seed 16 --verbose --output-dir gs://gpt-j-trainer-sql/data/
#python3 create_finetune_tfrecords.py ./data/sql_data/validation_wikisql.txt "validation_wikisql" --normalize-with-ftfy --output-dir gs://gpt-j-trainer-sql/data/

# To run training with a config and a previous saved model checkpoint
python3 ./device_train.py --config=$CONFIG_FILE --tune-model-path=gs://gpt-j-trainer-sql/step_383500/

# To make this model available for testing

# you can find the correct one in the cloud bucket at gpt-j-trainer-sql/
#CHECKPOINT_TO_SAVE=1438

python3 slim_model.py --config="./configs/combined_bsize8.json" --f16

cp -r ./slim_model/ ./home/jha0007/api-gpt/slim_model/
nohup python3 ./home/jha0007/api-gpt/serve.py &


# To convert the model to fp16 for tpu inference, select a saved version

# To convert the model to pytorch weights for hugging face inference
#python3 ./to_hf_weights.py --input-ckpt "gs://gpt-j-trainer-sql/sql_cleaned_slim_f16/step_""$CHECKPOINT_TO_SAVE" --config $CONFIG_FILE --output-path "gs://gpt-j-trainer-sql/hf_"$CHECKPOINT_TO_SAVE/ --cpu
