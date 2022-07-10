#!/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS=/home/jha0007/sac.json

CONFIG_FILE_NAME=$(openssl rand -hex 20)
CONFIG_FILE="./configs/${CONFIG_FILE_NAME}.json"

# To convert the data to tfrecords and upload to bucket

if [ $TRAIN_FILE != "default" ]; then
    rm "./data/sql_data/${TRAIN_FILE}.txt"
    gsutil -m cp "gs://gpt-j-trainer-sql/dataset/${TRAIN_FILE}.txt" "./data/sql_data/${TRAIN_FILE}.txt"
    TFRECORDS_TRAIN=$(python3 create_finetune_tfrecords.py "./data/sql_data/${TRAIN_FILE}.txt" $TRAIN_FILE --normalize-with-ftfy --n-repack-epochs 1 --seed 16 --verbose --output-dir gs://gpt-j-trainer-sql/data/)
else
    echo "Train File not found. Stopping!!!"
    exit 1
fi

if [ $VAL_FILE != "default" ]; then
    rm "./data/sql_data/${VAL_FILE}.txt"
    gsutil -m cp "gs://gpt-j-trainer-sql/dataset/${VAL_FILE}.txt" "./data/sql_data/${VAL_FILE}.txt"
    TFRECORDS_VAL=$(python3 create_finetune_tfrecords.py "./data/sql_data/${VAL_FILE}.txt" $VAL_FILE --normalize-with-ftfy --output-dir gs://gpt-j-trainer-sql/data/)
else
    echo "Validation File not found. SKIPPING!!!"
fi

python3 ./generate_configs.py $CONFIG_FILE $TRAIN_FILE $VAL_FILE $TFRECORDS_TRAIN $TFRECORDS_VAL $LR_START $LR_END $MODEL_DIR

# To run training with a config and a previous saved model checkpoint
python3 ./device_train.py --config=./configs/wikisql_matchformat.json --tune-model-path=gs://gpt-j-trainer-sql/step_383500/

# To make this model available for testing

# you can find the correct one in the cloud bucket at gpt-j-trainer-sql/
#CHECKPOINT_TO_SAVE=1438

#python3 ~/mesh-transformer/create_finetune_tfrecords.py /home/jha0007/bigdiks/github-downloader/github_data "sql_train" --output-dir=/home/jha0007/bigdiks/ --normalize-with-ftfy
python3 slim_model.py --config=$CONFIG_FILE --f16
#
cp -r gs://gpt-j-trainer-sql/gpt_sql_slim_wsql/ ./home/jha0007/bigdiks/slim_model/
#nohup python3 ./home/jha0007/api-gpt/serve.py &

python3 -m streamlit run streamlit_app.py --server.port 8000
# To convert the model to fp16 for tpu inference, select a saved version

# To convert the model to pytorch weights for hugging face inference
#python3 ./to_hf_weights.py --input-ckpt "gs://gpt-j-trainer-sql/sql_cleaned_slim_f16/step_""$CHECKPOINT_TO_SAVE" --config $CONFIG_FILE --output-path "gs://gpt-j-trainer-sql/hf_"$CHECKPOINT_TO_SAVE/ --cpu
