### ABAP global memory solution on data cluster table
ABAP class for work with global memory data.
It's a simple solution on single ABAP class for fast use. Solution was successfully tested on 
multiinstance SAP systems (>1 SAP AS) .
Pros:
- all in one abap class zcl_gdc;
- data stored in internal abal table in form on collection <property_id, property_value>;
- predefined methods to store sap messages;
- to share data between process you need use predefined or generate unique GUID (see example in zcl_gdc=>test( );
- gobal data stored in cluster table in BLOB field in JSON format;
Cons:
- current release not support parallel changing of one area from 2 or more parallel process;


