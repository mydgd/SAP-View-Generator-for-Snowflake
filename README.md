# SAP-View-Generator-for-Snowflake
This is a Snowflake stored procedure to generate views on raw SAP tables with meaningful column names

```sql
CALL sp_generate_sap_views(
        array_construct('BSEG','MARA'), -- list of tables
        'SAP_PLAYGROUND.RAW', --source schema to read SAP tables from
        'SAP_PLAYGROUND.RAW', -- target schema to create views
        'SAP_PLAYGROUND.RAW.DD03M', -- SAP Dictionary table DD03M
        'E' -- Language
    );
```
