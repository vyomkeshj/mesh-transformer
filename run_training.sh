#!/bin/bash
export GOOGLE_APPLICATION_CREDENTIALS=/home/jha0007/sac.json
CONFIG_FILE="./configs/wikisql_matchformat.json"

# To convert the data to tfrecords and upload to bucket
#python3 create_finetune_tfrecords.py ./data/sql_data/train_wsql_mf.txt "wsql_reformat_train" --normalize-with-ftfy --n-repack-epochs 1 --seed 16 --verbose --output-dir gs://gpt-j-trainer-sql/data/
#python3 create_finetune_tfrecords.py ./data/sql_data/test_wsql_mf.txt "wsql_reformat_val" --normalize-with-ftfy --output-dir gs://gpt-j-trainer-sql/data/
python3 create_finetune_tfrecords.py ./data/sql_data/interleaved.txt "interleaved" --normalize-with-ftfy --output-dir gs://gpt-j-trainer-sql/data/ --n-repack-epochs 4

# To run training with a config and a previous saved model checkpoint
python3 ./device_train.py --config=./configs/interleaved.json --tune-model-path=gs://gpt-j-trainer-sql/sql_pile_reduced2/gpt_sql/
python3 ./device_train.py --config=./configs/spider_no_join.json --tune-model-path=gs://gpt-j-trainer-sql/wikisql_after_retraining/

# To make this model available for testing

# you can find the correct one in the cloud bucket at gpt-j-trainer-sql/
#CHECKPOINT_TO_SAVE=1438

#python3 ~/mesh-transformer/create_finetune_tfrecords.py /home/jha0007/bigdiks/github-downloader/github_data "sql_train" --output-dir=/home/jha0007/bigdiks/ --normalize-with-ftfy
python3 slim_model.py --config=$CONFIG_FILE --f16
#
cp -r gs://gpt-j-trainer-sql/gpt_sql_pile_wsql_train2/ /home/jha0007/bigdiks/slim_model/
#nohup python3 serve.py &

python3 -m streamlit run streamlit_app.py --server.port 8000
# To convert the model to fp16 for tpu inference, select a saved version
python3 slim_model.py --config="./configs/pile.json" --f16 --cpu
# To convert the model to pytorch weights for hugging face inference
python3 ./to_hf_weights.py --input-ckpt "gs://gpt-j-trainer-sql/gpt-sql-pile/" --config ./configs/pile.json --output-path "gs://gpt-j-trainer-sql/hf_sql_retrain"

python3 slim_model.py --config="./configs/interleaved.json" --f16

python3 slim_model.py --config="./configs/pile_reduced2.json" --f16

gsutil cp -r gs://gpt-j-trainer-sql/gpt_sql_pile_wsql_train3/ /home/jha0007/bigdiks/slim_model/

#python3 create_finetune_tfrecords.py ./data/sql_data/test_wsql_mf.txt "wsql_reformat_val" --normalize-with-ftfy --output-dir gs://gpt-j-trainer-sql/data/
