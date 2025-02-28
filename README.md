# Add notes from CLI and save to MongoDB

A bash script that allows you to write short notes in the CLI and save them to MongoDB.

You can specify the connection string in a file called "config.yaml" in the following format:

```
uri: mongodb+srv://cluster7.something.mongodb.net/
```

Alternatively you will be prompted for the connection string when running the script.

## Run

After downloading the repo, you can run the script by entering the following command when inside the repo folder:

```
./save
```

The save script uses the following defaults:

```
# Change this to your database name
dbName="notes"
# Change this to your collection name
collectionName="general"
```

Update them to the database name and collection you want to use.

## Tests

To run tests, [the bats-core testing system](https://bats-core.readthedocs.io/en/stable/installation.html) is required.

Tests can be run with the following command:

```
bats tests/save.bats
```
