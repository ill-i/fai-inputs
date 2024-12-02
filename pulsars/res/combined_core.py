import os
import sqlite3
from gavo import api

class Core(api.Core):
    inputTableXML = """
        <inputTable>
            <inputKey name="Name" type="text" multiplicity="single" required="False"
                description="Name of the object to retrieve (leave empty to match all)" />
            <inputKey name="persistent" type="boolean" multiplicity="single" required="False"
                description="Fetch persisten objects only" />
            <inputKey name="transient" type="boolean" multiplicity="single" required="False"
                description="Fetch transient objects only" />
        </inputTable>
    """

    def initialize(self):
        # Define the output table based on the 'combined_table' in the RD
        self.outputTable = api.OutputTableDef.fromTableDef(
            self.rd.getById("combined_table"), None)

    def run(self, service, inputTable, queryMeta):
        # Extract input parameters
        name = inputTable.getParam("Name") or ''
        persistent = inputTable.getParam("persistent")
        if persistent is not None:
            persistent = int(persistent)

        transient = inputTable.getParam("transient")
        if transient is not None:
            transient = int(transient)
        # Build SQL query dynamically based on inputs
        query = "SELECT * FROM combined_table"
        params = []
        conditions = []

        if name:
            conditions.append("Name LIKE ?")
            params.append(f"%{name}%")
        if persistent:
            conditions.append("persistent = 1")
            # params.append(persistent)
        if transient:
            conditions.append("persistent = 0")
            # params.append(transient)

        if conditions:
            query += " WHERE " + " AND ".join(conditions)

        # Path to the SQLite3 database file
        db_path = os.path.join(os.path.dirname(__file__), 'data.db')

        # Initialize conn to None before the try block
        conn = None
        try:
            conn = sqlite3.connect(db_path)
            conn.row_factory = sqlite3.Row  # Access columns by name
            cursor = conn.cursor()
            cursor.execute(query, params)
            rows = cursor.fetchall()
        except sqlite3.Error as e:
            raise api.ReportableError(what=f"Database error: {str(e)}")
        finally:
            # Ensure conn is closed if it was successfully opened
            if conn:
                conn.close()

        # Prepare rows for output
        output_rows = [dict(row) for row in rows]

        # Return the table with all columns
        return api.TableForDef(self.outputTable, rows=output_rows)

