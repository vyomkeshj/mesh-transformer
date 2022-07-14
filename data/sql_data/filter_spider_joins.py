
spider_file = open('spider_reformat.txt', 'r')
spider_file_no_join = open('spider_reformat_nj.txt', 'w')

local_buffer = []

while True:
    # Get next line from file
    line = spider_file.readline()
    local_buffer.append(line)

    if "SELECT" in line:
        if "JOIN" in line:
            local_buffer = []
        else:
            spider_file_no_join.writelines(local_buffer)
            local_buffer = []

    if not line:
        break

spider_file.close()
spider_file_no_join.close()

# Writing to a file

# Using readline()