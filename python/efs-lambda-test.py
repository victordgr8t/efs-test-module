import os


def lambda_handler(event, context):
    # Define the path to the EFS file
    efs_path = "/mnt/efs/test.txt"

    # String to write to the file
    test_string = "Hello, EFS from Lambda!"

    # Write the string to the file
    with open(efs_path, "w") as file:
        file.write(test_string)

    # Read the content back from the file
    with open(efs_path, "r") as file:
        content = file.read()

    # Verify the content
    if content == test_string:
        return {"statusCode": 200, "body": "String verification successful!"}
    else:
        return {"statusCode": 400, "body": "String verification failed!"}
