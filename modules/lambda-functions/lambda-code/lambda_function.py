def lambda_handler(event: dict, context: object):
    """
    AWS Lambda function to process media files.

    This is a placeholder function that logs the received event and returns a
    success response.
    """
    # Log the received event
    print("Received event:", event)

    # Return a success response
    return {
        'statusCode': 200,
        'body': 'OK'
    }
