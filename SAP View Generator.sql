CREATE OR REPLACE PROCEDURE sp_generate_sap_views(table_names array, source_db_schema varchar, target_db_schema varchar, dd03m_TABLE varchar, lang varchar) 
    RETURNS varchar 
    LANGUAGE javascript AS 
    $$
var results = [];
var result = "";

for (var table_num = 0; table_num < TABLE_NAMES.length; table_num = table_num + 1) {
    var table_name = TABLE_NAMES[table_num].toUpperCase();
        
    var sql_command = "describe table " + SOURCE_DB_SCHEMA + "." + table_name;

    try {
        var table_definition_statement = snowflake.createStatement({ sqlText: sql_command });

        var table_description = table_definition_statement.execute();

        var rowCount = table_description.getRowCount(); //find number of columns in the table

        //start building SQL statement for creating the view
        var create_view_sql = "CREATE OR REPLACE VIEW " + TARGET_DB_SCHEMA + ".V_" + table_name + " AS SELECT ";
        var fieldNamesList = [];
        for (let step = 1; step <= rowCount; step++) {

            table_description.next();
            var column_name = table_description.getColumnValue(1);

            //find description of the column from the DD03M table.
            var fieldSQLText = "select DDTEXT from " + DD03M_TABLE + " where UPPER(DDLANGUAGE)='" + LANG + "' and UPPER(TABNAME)='" + table_name + "' and UPPER(FIELDNAME)='" + column_name.toUpperCase() + "';";

            try {
                var fieldDef = snowflake.createStatement({ sqlText: fieldSQLText });
                fieldDef1 = fieldDef.execute();
                fieldDef1.next();

                //replace gaps with underscore.
                var fieldName = fieldDef1.getColumnValue(1);

                fieldName = fieldName.replace(/[^a-zA-Z0-9 ]/g, '');
                fieldName = fieldName.replace(/\s/g, "_");

            }
            catch (err) {
                var fieldName = column_name;
            }

            //Check duplicate field description and append field name.
            if (fieldNamesList.includes(fieldName)) {
                fieldName = fieldName + '(' + column_name + ')';
            }

            fieldNamesList.push(fieldName);
            
            //add fields to SQL statement.
            create_view_sql += '"' + column_name + '" as "' + fieldName + '"';

            if (step != rowCount) {
                create_view_sql += ', ';
            }

        }

        create_view_sql += ' from ' + SOURCE_DB_SCHEMA + '.' + table_name;
        snowflake.createStatement({ sqlText: create_view_sql }).execute();
        result += table_name + ": SUCCESS";

    }
    catch (err) {
        result += table_name + ": FAILED. Column: "
        result += column_name;
        result += " --> " + err.message;
    }
    result += " \n";

}

return result;

$$;

CALL sp_generate_sap_views(
        array_construct('BSEG'), -- list of tables
        'SAP_PLAYGROUND.RAW', --source schema to read SAP tables from
        'SAP_PLAYGROUND.RAW', -- target schema to create views
        'SAP_PLAYGROUND.RAW.DD03M', -- SAP Dictionary table DD03M
        'E' -- Language
    );



desc view v_bseg;