import boto3
import ConfigParser
import botocore
import datetime
import re

config = ConfigParser.RawConfigParser()
config.read('./vars.ini')


AWS_SOURCE_REGION = config.get('main' ,'AWS_SOURCE_REGION')
AWS_DEST_REGION = config.get('main' ,'AWS_DEST_REGION')
SOURCE_DB = config.get('main' ,'SOURCE_DB')
KEEP = config.get('main' ,'KEEP')


print('Loading function')

def bySnapshotId(snap):
  return snap['DBSnapshotIdentifier']

def byTimestamp(snap):
  if 'SnapshotCreateTime' in snap:
    return datetime.datetime.isoformat(snap['SnapshotCreateTime'])
  else:
    return datetime.datetime.isoformat(datetime.datetime.now())

def lambda_handler(event, context):
  source = boto3.client('rds', region_name=AWS_SOURCE_REGION)
  source_snaps = source.describe_db_snapshots(SnapshotType='automated', DBInstanceIdentifier=SOURCE_DB)['DBSnapshots']
  source_snap = sorted(source_snaps, key=bySnapshotId, reverse=True)[0]['DBSnapshotIdentifier']
  source_snap_arn = 'arn:aws:rds:%s:%s:snapshot:%s' % (AWS_SOURCE_REGION, event['account'], source_snap)
  target_snap_id = 'copy-of-%s' % (re.sub('rds:', '', source_snap))
  print('Will Copy %s to %s' % (source_snap_arn, target_snap_id))

  target = boto3.client('rds', region_name=AWS_DEST_REGION)
  try:
    response = target.copy_db_snapshot(
      SourceDBSnapshotIdentifier=source_snap_arn,
      TargetDBSnapshotIdentifier=target_snap_id,
      CopyTags = True)
    print(response)
  except botocore.exceptions.ClientError as e:
    raise Exception("Could not issue copy command: %s" % e)

  copied_snaps = target.describe_db_snapshots(SnapshotType='manual', DBInstanceIdentifier=SOURCE_DB)['DBSnapshots']
  if len(copied_snaps) > 0:
    for snap in sorted(copied_snaps, key=byTimestamp, reverse=True)[KEEP:]:
      print('Will remove %s') % (snap['DBSnapshotIdentifier'])
      try:
        target.delete_db_snapshot(DBSnapshotIdentifier=snap['DBSnapshotIdentifier'])
      except botocore.exceptions.ClientError as e:
        raise Exception("Could not delete snapshot " + snap['DBSnapshotIdentifier'] + ": %s" % e)
