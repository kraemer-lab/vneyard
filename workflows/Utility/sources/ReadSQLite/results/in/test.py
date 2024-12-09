# Create a sqlite database, and populate table 'my_table' with a small sample dataset
import sqlite3

# Create a sqlite database
conn = sqlite3.connect('my_database.db')
c = conn.cursor()

# Create a table
c.execute('''CREATE TABLE my_table
             (id INTEGER PRIMARY KEY, name TEXT, value REAL)''')

# Insert some data
c.execute("INSERT INTO my_table (name, value) VALUES ('A', 1.0)")
c.execute("INSERT INTO my_table (name, value) VALUES ('B', 2.0)")
c.execute("INSERT INTO my_table (name, value) VALUES ('C', 3.0)")

# Commit the changes
conn.commit()

