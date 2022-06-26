## 1. Take the training + validation file as input
## 2. Run create_finetune_tfrecords on each (perpahs modify and import the functions?), upload to bucket (just pass gs:// path as output dir)
## 3. Create config for this training in configs directory, populate the fields based on number of tf_records produced and hyperparams.
## 4. Run training for this config, wait until it completes.
## 5. Convert the model to fp16 using slim_model.py
## 6. Deploy this model to an endpoint