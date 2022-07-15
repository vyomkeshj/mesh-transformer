import sys
import re
from rich.progress import track
import sqlparse

args = sys.argv

file_path = args[1]

with open(file_path, 'r') as json_file:
    json_list = list(json_file)
    result = []
    for row in track(json_list, description="Processing..."):
        items = sqlparse.parse(row)
        if "\\u" in row or "\u" in row or "\\N" in row or "\N" in row:
            continue
        # if (len(items) > 0) and ("select" in row.lower()) and ("from" in row.lower()):
        if len(items) > 0:
            res = row.replace("\\n", " ").replace("\\t", " ").replace("\\r", " ").replace("\n", " ").replace("\t", " ").replace("\r", " ").replace("\/", "/").replace("\x", "x").replace('\"', '"')
            res = re.sub('\s+', ' ', res)
            result.append(res)
    res_file_path = f"{file_path.split('.')[0]}_cleaned.{file_path.split('.')[1]}"
    with open(res_file_path, 'w') as res_file:
        res_file.write("\n".join(result))

print("Completed.")