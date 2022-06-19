import google.cloud.storage as storage

client = storage.Client()
bucket = storage_client.get_bucket('gpt-j-trainer-sql')

d = 'path/file.txt'
d = bucket.blob(d)
d.upload_from_string('V')
