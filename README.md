# SAP-View-Generator-for-Snowflake
This is a Snowflake stored procedure to generate views on raw SAP tables with meaningful column names.
It uses SAP's dictionary table DD03M to find matching descriptions for the original, usually 5 letter fields names.


###How to use###

1. Ingest your Raw tables from SAP to Snowflake, including DD03M table.
2. Create stored procedure in your Snowflake system. 
3. Run the stored procedure as shown below. You can provide multiple tables as an input and the SP will create a view for each table that you provide.

```sql
CALL sp_generate_sap_views(
        array_construct('BSEG','MARA'), -- list of tables
        'SAP_PLAYGROUND.RAW', --source schema to read SAP tables from
        'SAP_PLAYGROUND.RAW', -- target schema to create views
        'SAP_PLAYGROUND.RAW.DD03M', -- SAP Dictionary table DD03M
        'E' -- Language
    );
```
