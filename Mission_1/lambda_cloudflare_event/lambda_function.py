import boto3
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)  # Set logging level to INFO

def lambda_handler(event, context):
    ec2_client = boto3.client('ec2')
    rds_client = boto3.client('rds')

    # Get the current time in PHT
    current_time = datetime.now(tz=pytz.timezone('Asia/Manila')).strftime('%H:%M:%S')

    try:
        # Get the SpotFleetRequestId
        response = ec2_client.describe_spot_fleet_requests()
        spot_fleet_requests = response['SpotFleetRequestConfigs']
        spot_fleet_request_id = None
        for sfr in spot_fleet_requests:
            if sfr['SpotFleetRequestState'] == 'active':
                spot_fleet_request_id = sfr['SpotFleetRequestId']
                break

        if spot_fleet_request_id is None:
            logger.error("No active Spot Fleet Request found")
            return {
                'statusCode': 400,
                'body': 'No active Spot Fleet Request found'
            }

        # Get the DBInstanceIdentifier
        response = rds_client.describe_db_instances()
        db_instances = response['DBInstances']
        db_instance_identifier = None
        for db in db_instances:
            if db['DBInstanceStatus'] in ['available', 'stopping', 'stopped']:
                db_instance_identifier = db['DBInstanceIdentifier']
                break

        if db_instance_identifier is None:
            logger.error("No available or stopped RDS instance found")
            return {
                'statusCode': 400,
                'body': 'No available or stopped RDS instance found'
            }

        # Modify the target capacity of the Spot Fleet
        logger.info("Modifying Spot Fleet target capacity")
        ec2_client.modify_spot_fleet_request(
            SpotFleetRequestId=spot_fleet_request_id,
            TargetCapacity=2 if current_time == '08:00:00' else 0,
            ExcessCapacityTerminationPolicy='NoTermination'
        )

        # Start or stop the RDS instance based on the time
        if current_time == '08:00:00':
            logger.info("Starting RDS instance")
            rds_client.start_db_instance(
                DBInstanceIdentifier=db_instance_identifier
            )
        elif current_time == '17:00:00':
            logger.info("Stopping RDS instance")
            rds_client.stop_db_instance(
                DBInstanceIdentifier=db_instance_identifier
            )

        logger.info("Spot Fleet and RDS instance modified successfully")
        return {
            'statusCode': 200,
            'body': 'Spot fleet and RDS instance modified'
        }

    except Exception as e:
        logger.error("An error occurred: %s", e)
        return {
            'statusCode': 500,
            'body': 'Failed to modify Spot Fleet or RDS instance'
        }