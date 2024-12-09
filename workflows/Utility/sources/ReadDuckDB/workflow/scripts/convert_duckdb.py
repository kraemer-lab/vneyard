print("Running script")
import duckdb

conn = duckdb.connect(snakemake.input.db)
c = conn.cursor()
c.execute(f"SELECT {snakemake.params.fields} FROM \"{snakemake.params.table}\"")
with open(snakemake.output.outfile, "w") as f:
    for row in c.fetchall():
        f.write(str(row) + "\n")
conn.close()
