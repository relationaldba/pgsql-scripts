vacuumdb --dbname=dbname --analyze --echo --full --jobs=njobs --verbose --host=host --port=port --username=username 1>./"vacuumdb_"$(date +%Y_%m_%d_%H%M%S)".txt" 2>&1
