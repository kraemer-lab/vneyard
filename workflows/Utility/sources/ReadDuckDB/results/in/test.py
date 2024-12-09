# Create a duckdb database, and populate table 'my_table' with a small sample dataset
import duckdb

# Create a database
con = duckdb.connect('my_database.db')

# Create a table
con.execute("CREATE TABLE my_table (a INTEGER, b VARCHAR);")

# Insert some data
con.execute("INSERT INTO my_table VALUES (1, 'foo');")
con.execute("INSERT INTO my_table VALUES (2, 'bar');")
con.execute("INSERT INTO my_table VALUES (3, 'baz');")

# Close the connection
con.close()
