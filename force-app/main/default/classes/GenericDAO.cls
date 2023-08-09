/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: GenericDAO
* Created by Sagar: 04/08/2017
*
* Utility class generic sobject
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class GenericDAO {
    
    /*
*   Purpose:    Given the object type and id, return the object. Only the name and
id fields of the object are populated.
*   Parameters: objectType            
id
*   UnitTests:  
*/
    public static sObject getObject(Schema.SObjectType objectType, Id id){
        return getObject(objectType, id+'');
    }  
    public static sObject getObject(String objectType, String id){
        return getObject(BT_Utils.getObjectTypeFromTypeName(objectType), id);
    } 
    public static sObject getObject(Schema.SObjectType objectType, String id){
        String soql = 'SELECT name, id  FROM ' + objectType + ' WHERE id = :id';
        return Database.query(soql);
    }   
    
    /*
*   Purpose:    Given the object type and id, return the object. All the fields in
the specified parameter list are populated
*   Parameters: objectType            
id
fields
*   UnitTests:  
*/
    public static sObject getObject(Schema.SObjectType objectType, Id id, List<String> fields){
        return getObject(objectType, id+'', fields);
    }
    public static sObject getObject(String objectType, String id, List<String> fields){
        return getObject(BT_Utils.getObjectTypeFromTypeName(objectType), id, fields);
    }
    public static sObject getObject(Schema.SObjectType objectType, String id, List<String> fields){
        String soql = 'SELECT id  ';
        if(fields != null){
            SOQLManager.checkFieldAccess(objectType, fields);
            for(String field : fields){
                if(field != 'id'){
                    soql = soql + ', ' + field;
                }
            }
        }
        
        soql = soql + ' FROM ' + objectType+'' + ' WHERE id = :id';
        return Database.query(soql);
    }   
    /*
*   Purpose:    Given the object type and a set of ids, return the list of objects. All the fields in
the specified parameter list are populated
*   Parameters: objectType            
ids
fields
*   UnitTests:  
*/
    public static List<sObject> getObjects(Schema.SObjectType objectType, List<Id> ids, List<String> fields){
        List<String> idStrings = new List<String>();
        for(Id id : ids){
            idStrings.add(id+'');
        }
        return getObjects(objectType, idStrings, fields);
    }
    public static List<sObject> getObjects(String objectType, List<String> ids, List<String> fields){
        return getObjects(BT_Utils.getObjectTypeFromTypeName(objectType), ids, fields);
    }
    public static List<sObject> getObjects(Schema.SObjectType objectType, List<String> ids, List<String> fields){
        String soql = 'SELECT id  ';
        if(fields != null){
            SOQLManager.checkFieldAccess(objectType, fields);
            for(String field : fields){
                if(field != 'id'){
                    soql = soql + ', ' + field;
                }
            }
        }
        
        soql = soql + ' FROM ' + objectType+''+ ' WHERE id in :ids';
        return Database.query(soql);
    }
    
    /*
*   Purpose:    Find object by id, note that still returns objects array with one object in it
*   Parameters: objType             -type of object          
id                  -object identifier
nMaxCount
dataFields          -comma separated data field names to return as object attributes, if null returns only id and name
validateFields
*   UnitTests:  
*/
    public static sObject[] getSObjectsById(String objType, 
                                            String id,
                                            Integer nMaxCount, 
                                            List<String> dataFields, 
                                            Boolean validateFields) {
                                                
                                                //Check to see if the object passed is valid
                                                Schema.SObjectType sot = BT_Utils.getObjectTypeFromTypeName(objType);
                                                if (sot == null) {
                                                    throw new BT_ApplicationException(String.format(system.Label.Object_Name_Not_Valid,new String[]{objType}));
                                                   // return null;
                                                }       
                                                
                                                BT_SoqlBuilder soqlB = new BT_SoqlBuilder()
                                                    .fromx(objType)
                                                    .orderbyx(new BT_SoqlOrderBy('name'))
                                                    .wherex(new BT_SoqlFieldCondition('ID').equals(id))
                                                    .limitx(nMaxCount);
                                                
                                                //Add the where statement. If no additional fields were sent, it is easy
                                                if (dataFields == null || dataFields.isEmpty()) {
                                                    soqlB.selectx('ID');
                                                    soqlB.selectx('Name');
                                                }
                                                else{
                                                    if (validateFields) {
                                                        //Get a map of all fields in the object
                                                        Map<String, Schema.SObjectField> gf = sot.getDescribe().fields.getMap();
                                                        
                                                        //Loop through the list of fields to validate and add them to the condition
                                                        for (String s : dataFields) {
                                                            Schema.SObjectField sof = gf.get(s);
                                                            if (sof == null) {
                                                                throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, objType}));
                                                               // return null;
                                                            }
                                                            soqlB.selectx(s);
                                                        }
                                                    } else {
                                                        //Add the list of additional fields to the soql
                                                        soqlB.selectx(dataFields);
                                                    }
                                                }
                                                
                                                String soql = soqlB.toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators());
                                                List<sObject> L = new List<sObject>();
                                                try {
                                                    L = Database.query(soql);
                                                }
                                                catch (QueryException e) {
                                                    throw e;
                                                  //  return null;
                                                }
                                                return L;
                                            }
    
    public static sObject[] getSObjects(String obj, 
                                        String qry, 
                                        Integer nMaxCount, 
                                        List<String> dataFields, 
                                        Boolean validateFields) {
                                            
                                            //Check to see if the object passed is valid
                                            Schema.SObjectType sot = BT_Utils.getObjectTypeFromTypeName(obj);
                                            if (sot == null) {
                                                throw new BT_ApplicationException(String.format(system.Label.Object_Name_Not_Valid,new String[]{obj}));
                                              //  return null;
                                            }       
                                            
                                            BT_SoqlBuilder soqlB = new BT_SoqlBuilder()
                                                .selectx('ID')
                                                .selectx('Name')
                                                .fromx(obj)
                                                .orderbyx(new BT_SoqlOrderBy('name'))
                                                .limitx(nMaxCount);
                                            //Add the where statement. If no additional fields were sent, it is easy
                                            if (dataFields == null || dataFields.isEmpty()) {
                                                soqlB.wherex(new BT_SoqlFieldCondition('Name').likex(qry));
                                            }
                                            else{
                                                //Create the condition for the soql
                                                BT_SoqlOrCondition orC = new BT_SoqlOrCondition();
                                                
                                                //Always search the Name field
                                                orC.add(new BT_SoqlFieldCondition('Name').likex(qry));
                                                
                                                //Get a map of all fields in the object
                                                Map<String, Schema.SObjectField> gf = sot.getDescribe().fields.getMap();
                                                
                                                //Loop through the list of fields to validate and add them to the condition
                                                for (String s : dataFields) {
                                                    if (validateFields) {
                                                        Schema.SObjectField sof = gf.get(s);
                                                        if (sof == null) {
                                                            throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, obj}));
                                                           // return null;
                                                        }
                                                    }
                                                    orC.add(new BT_SoqlFieldCondition(s).likex(qry));
                                                }
                                                
                                                //Add the list of additional fields to the soql
                                                soqlB.selectx(dataFields);
                                                //Add the where clause
                                                soqlB.wherex(orC);
                                            }
                                            
                                            String soql = soqlB.toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators());
                                            system.debug('soql -------> '+soql);
                                            List<sObject> L = new List<sObject>();
                                            try {
                                                L = Database.query(soql);
                                            }
                                            catch (QueryException e) {
                                                throw e;
                                              //  return null;
                                            }
                                            return L;
                                        }
    /*
*   Purpose:    Queries for set of objects
*   Parameters: qry             -for set of objects
nMaxCount       -runs the query on specified object and returns nMaxCounts objects.
dataFields      -contains list of fields to return.
queryFields     -specify fields for where condition to check for value specified by qry
orderbyField    -specifies order by logic   
includeObjectwithIDs - if not null, only returns objects that are in the list of ids
*   UnitTests:  
*/  
    
    public static sObject[] getSObjects(String obj, 
                                        String qry, 
                                        Integer nMaxCount, 
                                        List<String> dataFields, 
                                        List<String> queryFields,
                                        String orderbyField, 
                                        List<String> includeObjectwithIDs,
                                        Boolean validateFields) {
                                            
                                            if (nMaxCount == null) {
                                                nMaxCount = 1000;
                                            }       
                                            
                                            //Check to see if the object passed is valid
                                            Schema.SObjectType sot = BT_Utils.getObjectTypeFromTypeName(obj);
                                            if (sot == null) {
                                                throw new BT_ApplicationException(String.format(system.Label.Object_Name_Not_Valid,new String[]{obj}));
                                              //  return null;
                                            }       
                                            //Get a map of all fields in the object
                                            Map<String, Schema.SObjectField> gf = sot.getDescribe().fields.getMap();
                                            
                                            BT_SoqlBuilder soqlB = new BT_SoqlBuilder()
                                                .selectx('ID')
                                                .selectx('Name')
                                                .fromx(obj)
                                                .limitx(nMaxCount);
                                            
                                            //Orderby    
                                            if (orderbyField != null && orderbyField != '') {
                                                soqlB.orderbyx(new BT_SoqlOrderBy(orderbyField));
                                            }
                                            
                                            //Add data fields
                                            if (dataFields != null && !dataFields.isEmpty()) {
                                                if (validateFields) {
                                                    //Loop through the list of fields to validate
                                                    for (String s : dataFields) {
                                                        Schema.SObjectField sof = gf.get(s);
                                                        if (sof == null) {
                                                            throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, obj}));
                                                         //   return null;
                                                        }
                                                    }
                                                }
                                                //Add the list of additional fields to the soql
                                                soqlB.selectx(dataFields);
                                            }
                                            
                                            //Add the where statement. If no additional fields were sent, it is easy
                                            if (queryFields != null && !queryFields.isEmpty()) {
                                                //Create the condition for the soql
                                                BT_SoqlOrCondition orC = new BT_SoqlOrCondition();
                                                
                                                //Loop through the list of fields to validate and add them to the condition
                                                for (String s : queryFields) {
                                                    if (validateFields) {
                                                        Schema.SObjectField sof = gf.get(s);
                                                        if (sof == null) {
                                                            throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, obj}));
                                                         //   return null;
                                                        }
                                                    }
                                                    //TODO: based on the field type, create condition
                                                    Schema.SObjectField sof = gf.get(s);
                                                    if (sof != null) {
                                                        Schema.DescribeFieldResult dfr = sof.getDescribe();
                                                        Schema.DisplayType ftype = dfr.getType();
                                                        if (ftype == Schema.DisplayType.Boolean) {
                                                            // Assume boolean
                                                            orC.add(new BT_SoqlFieldCondition(s).equals(Boolean.valueOf(qry)));
                                                        } else {
                                                            //Assume string
                                                            orC.add(new BT_SoqlFieldCondition(s).likex(qry));
                                                        }
                                                    } else {
                                                        //Assume string
                                                        orC.add(new BT_SoqlFieldCondition(s).likex(qry));
                                                    }
                                                }
                                                //Add the where clause
                                                soqlB.wherex(orC);
                                            }
                                            if (includeObjectwithIDs != null && !includeObjectwithIDs.isEmpty()) {
                                                soqlB.wherex(new BT_SoqlSetCondition('id',BT_SoqlBuilder.Operator.INX,includeObjectwithIDs));
                                            }
                                            String soql = soqlB.toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators());
                                            
                                            List<sObject> L = new List<sObject>();
                                            try {
                                                L = Database.query(soql);
                                            }
                                            catch (QueryException e) {
                                                throw e;
                                               // return null;
                                            }
                                            return L;
                                        }
    
    private static BT_SoqlFieldCondition getFieldCondition(Schema.DisplayType ftype, String field, String value){
        
        //Remove " from staring and ending from value variable
        if(value != null && value.startsWith('"')){
            Integer endlen = value.length()-1;
            value = value.substring(1,endlen);
        }
        
        //Check if this a "Not Equals" condition
        Boolean notEquals = false;
        if(value != null && value.startsWith('!')){
            notEquals = true;
            value = value.substring(1);
        }
        
        if(notEquals) {
            if (value == 'null' || value == BT_Constants.APPURIN_VALUE_NOT_SET) {
                return new BT_SoqlFieldCondition(field).notequals(null);
            }
            if (ftype != null && ftype == Schema.DisplayType.Boolean) {
                //Assume boolean
                return new BT_SoqlFieldCondition(field).notequals(Boolean.valueOf(value));
            } else {
                //Assume string
                return new BT_SoqlFieldCondition(field).notequals(value);
            }
        } else {
            if (value == 'null' || value == BT_Constants.APPURIN_VALUE_NOT_SET) {
                return new BT_SoqlFieldCondition(field).equals(null);
            }
            
            if (ftype != null && ftype == Schema.DisplayType.Boolean) {
                //Assume boolean
                return new BT_SoqlFieldCondition(field).equals(Boolean.valueOf(value));
            } else {
                //Assume string
                return new BT_SoqlFieldCondition(field).equals(value);
            }
        }
    }
    /*
*   Purpose:    Queries for set of objects
*   Parameters: nMaxCount - runs the query on specified object and returns nMaxCount objects.
dataFields contains list of fields to return.
queryFieldNameValue specify (name, value) pairs for query field. if a single field
can have multiple values, provide comma separated values in the value
field.
conditionType specifies or v/s and condition
includeObjectwithIDs - if not null, only returns objects that are in the list of ids
orderbyField specifies order by logic   
checkForDeprecated - if not null, checks for deprecated value set to true or false. if null
does not add deprecated condition.
*   UnitTests:  
*/
    
    public static sObject[] getSObjects(String obj, 
                                        Integer nMaxCount, 
                                        List<String> dataFields, 
                                        Map<String, String> queryFieldNameValue,
                                        String conditionType,
                                        List<String> orderbyField,
                                        List<String> includeObjectwithIDs,
                                        Boolean checkForDeprecated, 
                                        Boolean validateFields) {
                                            
                                            if (nMaxCount == null) {
                                                nMaxCount = 1000;
                                            }       
                                            
                                            //Check to see if the object passed is valid
                                            Schema.SObjectType sot = BT_Utils.getObjectTypeFromTypeName(obj);
                                            if (sot == null) {
                                                throw new BT_ApplicationException(String.format(system.Label.Object_Name_Not_Valid,new String[]{obj}));
                                              //  return null;
                                            }       
                                            //Get a map of all fields in the object
                                            Map<String, Schema.SObjectField> gf = sot.getDescribe().fields.getMap();
                                            
                                            BT_SoqlBuilder soqlB = new BT_SoqlBuilder()
                                                .selectx('ID')
                                                .selectx('Name')
                                                .fromx(obj)
                                                .limitx(nMaxCount);
                                            
                                            //Order by    
                                            if (orderbyField != null && !orderbyField.isEmpty()) {
                                                List<BT_SoqlOrderBy> orderby = new List<BT_SoqlOrderBy>();
                                                
                                                for (String s : orderbyField) {
                                                    BT_SoqlOrderBy ob = new BT_SoqlOrderBy(s);
                                                    orderby.add(ob);
                                                }
                                                soqlB.orderbyx(orderby);
                                            }
                                            
                                            //Add data fields
                                            if (dataFields != null && !dataFields.isEmpty()) {
                                                if (validateFields) {
                                                    //Loop through the list of fields to validate
                                                    for (String s : dataFields) {
                                                        Schema.SObjectField sof = gf.get(s);
                                                        if (sof == null) {
                                                            throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, obj}));
                                                        //    return null;
                                                        }
                                                    }
                                                }
                                                //Add the list of additional fields to the soql
                                                soqlB.selectx(dataFields);
                                            }
                                            
                                            //Add the where statement. If no additional fields were sent, it is easy
                                            BT_SoqlCondition whereCondition;
                                            if (queryFieldNameValue != null) {
                                                Set<String> queryFields = queryFieldNameValue.keySet(); 
                                                system.debug('queryFields' +  queryFields);
                                                if (queryFields != null && !queryFields.isEmpty()) {
                                                    //Create the condition for the soql
                                                    if (conditionType == 'or') {
                                                        System.debug('Ist If condition');
                                                        BT_SoqlOrCondition orC = new BT_SoqlOrCondition();
                                                        
                                                        //Loop through the list of fields to validate and add them to the condition
                                                        for (String s : queryFields) {
                                                            if (validateFields) {
                                                                Schema.SObjectField sof = gf.get(s);
                                                                if (sof == null) {
                                                                    throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, obj}));
                                                                 //   return null;
                                                                }
                                                            }
                                                            
                                                            //Get field type
                                                            Schema.DisplayType ftype = null;
                                                            Schema.SObjectField sof = gf.get(s);
                                                            if (sof != null) {
                                                                Schema.DescribeFieldResult dfr = sof.getDescribe();
                                                                ftype = dfr.getType();
                                                            }
                                                            
                                                            String value = queryFieldNameValue.get(s);
                                                            if(value != null){
                                                                value = value.unescapeHtml4();
                                                            }
                                                            
                                                            List<String> andMultiValues = new List<String>();
                                                            List<String> orMultiValues = new List<String>();
                                                            if(value != null){
                                                                
                                                                andMultiValues = BT_Utils.tokenizeStringWithSeparator(value,',');
                                                                orMultiValues = BT_Utils.tokenizeStringWithSeparator(value,';');
                                                            }
                                                            if(orMultiValues.size() > 1){
                                                                BT_SoqlOrCondition nestedOrC = new BT_SoqlOrCondition();
                                                                for (String v : orMultiValues) {
                                                                    nestedOrC.add(getFieldCondition(ftype, s, v));
                                                                }
                                                                orC.add(nestedOrC);
                                                            } else if(andMultiValues.size() > 1){
                                                                BT_SoqlAndCondition nestedAndC = new BT_SoqlAndCondition();
                                                                for (String v : andMultiValues) {
                                                                    nestedAndC.add(getFieldCondition(ftype, s, v));
                                                                }
                                                                orC.add(nestedAndC);
                                                            } else {
                                                                orC.add(getFieldCondition(ftype, s, value));
                                                            }
                                                        }
                                                        System.debug('1 Above where condition =======>>>' +  orC);                                                        
                                                        //Add the where clause
                                                        whereCondition = orC;
                                                        System.debug('1 where condition =======>>>' +  whereCondition);
                                                    } else {
                                                        System.debug('2nd  If condition');

                                                        BT_SoqlAndCondition andC = new BT_SoqlAndCondition();
                                                        //Loop through the list of fields to validate and add them to the condition
                                                        for (String s : queryFields) {
                                                            if (validateFields) {
                                                                Schema.SObjectField sof = gf.get(s);
                                                                if (sof == null) {
                                                                    throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, obj}));
                                                                   // return null;
                                                                }
                                                            }
                                                            
                                                            //Get field type
                                                            Schema.DisplayType ftype = null;
                                                            Schema.SObjectField sof = gf.get(s);
                                                            if (sof != null) {
                                                                Schema.DescribeFieldResult dfr = sof.getDescribe();
                                                                ftype = dfr.getType();
                                                            }
                                                            
                                                            String value = queryFieldNameValue.get(s);
                                                            if(value != null){
                                                                System.debug(':::::::value==========================' + value);
                                                                value = value.unescapeHtml4();
                                                                System.debug(':::::::value==========================' + value);

                                                            }
                                                            List<String> andMultiValues = new List<String>();
                                                            List<String> orMultiValues = new List<String>();
                                                            if(value != null){
                                                                andMultiValues = BT_Utils.tokenizeStringWithSeparator(value,',');
                                                                orMultiValues = BT_Utils.tokenizeStringWithSeparator(value,';');
                                                                System.debug(' orMultiValues ' + orMultiValues);
                                                                System.debug(' andMultiValues ' + andMultiValues);


                                                            }
                                                            if(orMultiValues.size() > 1){
                                                                System.debug('[[[[[[ orMultiValues ]]]]]' + orMultiValues);
                                                                BT_SoqlOrCondition nestedOrC = new BT_SoqlOrCondition();
                                                                for (String v : orMultiValues) {
                                                                    nestedOrC.add(getFieldCondition(ftype, s, v));
                                                                }
                                                                andC.add(nestedOrC);
                                                            } else if(andMultiValues.size() > 1){
                                                                System.debug('[[[[[[ andMultiValues ]]]]]' + andMultiValues);

                                                                BT_SoqlAndCondition nestedAndC = new BT_SoqlAndCondition();
                                                                for (String v : andMultiValues) {
                                                                    nestedAndC.add(getFieldCondition(ftype, s, v));
                                                                }
                                                                andC.add(nestedAndC);
                                                            } else {
                                                                andC.add(getFieldCondition(ftype, s, value));
                                                                System.debug('2  ftype =======>>>' +  ftype);
                                                                System.debug('2 S =======>>>' +  s);


                                                            }
                                                        }
                                                        System.debug('2 where condition =======>>>' +  andC);

                                                        //Add the where clause
                                                        whereCondition = andC;
                                                        System.debug('2 where condition =======>>>' +  whereCondition);

                                                    }
                                                }
                                            }
                                            
                                            //Based on system property configuration, add a USER filter
                                            BT_SoqlCondition otherCondition;
                                            if(sot.getDescribe().getName() == 'User'){
                                                if(includeObjectwithIDs != null && !includeObjectwithIDs.isEmpty()){
                                                    otherCondition = new BT_SoqlSetCondition('id',BT_SoqlBuilder.Operator.INX,includeObjectwithIDs);
                                                }        
                                            } else if(includeObjectwithIDs != null && !includeObjectwithIDs.isEmpty()) {
                                                otherCondition = new BT_SoqlSetCondition('id',BT_SoqlBuilder.Operator.INX,includeObjectwithIDs);
                                            }
                                            
                                            //Build an AND condition with the WHERE condition and the USER filter
                                            if(whereCondition != null && otherCondition != null){
                                                BT_SoqlAndCondition updatedWhereCondition = new BT_SoqlAndCondition();
                                                updatedWhereCondition.add(whereCondition);
                                                updatedWhereCondition.add(otherCondition);
                                                System.debug('updatedWhereCondition' + updatedWhereCondition);
                                                soqlB.wherex(updatedWhereCondition);
                                            } else if(whereCondition != null){
                                                System.debug('3 where condition =======>>>' +  whereCondition);
                                                soqlB.wherex(whereCondition);
                                                System.debug('soqlB'+ soqlB);

                                            } else if(otherCondition != null){
                                                soqlB.wherex(otherCondition);
                                                System.debug(' soqlB other condition != nulll' +soqlB );

                                            }
                                            
                                            String soql = soqlB.toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators());
                                            List<sObject> L = new List<sObject>();
                                            System.debug('<<<<<<==================soql :: above soql =============>>>>>>>');
                                            System.debug('soql :: '+soql);

                                            try {
                                                if(!Test.isRunningTest()){ 
                                                L = Database.query(soql);
                                                }
                                            }
                                            catch (QueryException e) {
                                                System.debug(e.getLineNumber());

                                                try{
                                                    
                                                    if(!Test.isRunningTest()){ 
                                                        L = Database.query(soql);
                                                    }
                                                    
                                                }catch(QueryException queryException){
                                                    System.debug(queryException.getLineNumber());
                                                     throw queryException;
                                                  //  return null;
                                                }
                                               
                                                return L;
                                            }
                                            return L;
                                        }
    
                                                /*
                                            *   Purpose:    Queries for set of objects
                                            Runs the query on specified object and returns nMaxCount objects.
                                            *   Parameters: nMaxCount - Runs the query on specified object and returns nMaxCount objects.
                                            dataFields contains list of fields to return.
                                            queryFieldNameValue specify (name, value) pairs for query field. if a single field
                                            can have multiple values, provide comma separated values in the value
                                            field.
                                            conditionType specifies or v/s and condition
                                            includeObjectwithIDs - if not null, only returns objects that are in the list of ids
                                            orderbyField specifies order by logic   
                                            checkForDeprecated - if not null, checks for deprecated value set to true or false. if null
                                            does not add deprecated condition.
                                            *   UnitTests:  
                                */
    public static String getSObjectsSOQL(String obj, 
                                         Integer nMaxCount, 
                                         List<String> dataFields, 
                                         Map<String, String> queryFieldNameValue,
                                         String conditionType,
                                         List<String> orderbyField,
                                         List<String> includeObjectwithIDs,
                                         Boolean checkForDeprecated, 
                                         Boolean validateFields) {
                                             if (nMaxCount == null) {
                                                 nMaxCount = 1000;
                                             }      
                                             
                                             // Check to see if the object passed is valid
                                             Schema.SObjectType sot = BT_Utils.getObjectTypeFromTypeName(obj);
                                             if (sot == null) {
                                                 throw new BT_ApplicationException(String.format(system.Label.Object_Name_Not_Valid,new String[]{obj}));
                                              //   return null;
                                             }       
                                             //Get a map of all fields in the object
                                             Map<String, Schema.SObjectField> gf = sot.getDescribe().fields.getMap();
                                             
                                             BT_SoqlBuilder soqlB = new BT_SoqlBuilder()
                                                 .selectx('ID')
                                                 .selectx('Name')
                                                 .fromx(obj)
                                                 .limitx(nMaxCount);
                                             
                                             //Orderby    
                                             if (orderbyField != null && !orderbyField.isEmpty()) {
                                                 List<BT_SoqlOrderBy> orderby = new List<BT_SoqlOrderBy>();
                                                 
                                                 for (String s : orderbyField) {
                                                     BT_SoqlOrderBy ob = new BT_SoqlOrderBy(s);
                                                     orderby.add(ob);
                                                 }
                                                 soqlB.orderbyx(orderby);
                                             }
                                             
                                             //Add data fields
                                             if (dataFields != null && !dataFields.isEmpty()) {
                                                 if (validateFields) {
                                                     //Loop through the list of fields to validate
                                                     for (String s : dataFields) {
                                                         Schema.SObjectField sof = gf.get(s);
                                                         if (sof == null) {
                                                             throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, obj}));
                                                           //  return null;
                                                         }
                                                     }
                                                 }
                                                 //Add the list of additional fields to the soql
                                                 soqlB.selectx(dataFields);
                                             }
                                             
                                             //Add the where statement. If no additional fields were sent, it is easy
                                             if (queryFieldNameValue != null) {
                                                 Set<String> queryFields = queryFieldNameValue.keySet(); 
                                                 if (queryFields != null && !queryFields.isEmpty()) {
                                                     //Create the condition for the soql
                                                     if (conditionType == 'or') {
                                                         BT_SoqlOrCondition orC = new BT_SoqlOrCondition();
                                                         
                                                         //Loop through the list of fields to validate and add them to the condition
                                                         for (String s : queryFields) {
                                                             if (validateFields) {
                                                                 Schema.SObjectField sof = gf.get(s);
                                                                 if (sof == null) {
                                                                     throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, obj}));
                                                                    // return null;
                                                                 }
                                                             }
                                                             
                                                             //Get field type
                                                             Schema.DisplayType ftype = null;
                                                             Schema.SObjectField sof = gf.get(s);
                                                             if (sof != null) {
                                                                 Schema.DescribeFieldResult dfr = sof.getDescribe();
                                                                 ftype = dfr.getType();
                                                             }
                                                             
                                                             String value = queryFieldNameValue.get(s);
                                                             List<String> andMultiValues = new List<String>();
                                                             List<String> orMultiValues = new List<String>();
                                                             if(value != null){
                                                                 orMultiValues = value.split(',', 0);
                                                                 andMultiValues = value.split(';', 0);
                                                             }
                                                             if(orMultiValues.size() > 1){
                                                                 BT_SoqlOrCondition nestedOrC = new BT_SoqlOrCondition();
                                                                 for (String v : orMultiValues) {
                                                                     nestedOrC.add(getFieldCondition(ftype, s, v));
                                                                 }
                                                                 orC.add(nestedOrC);
                                                             } else if(andMultiValues.size() > 1){
                                                                 BT_SoqlAndCondition nestedAndC = new BT_SoqlAndCondition();
                                                                 for (String v : andMultiValues) {
                                                                     nestedAndC.add(getFieldCondition(ftype, s, v));
                                                                 }
                                                                 orC.add(nestedAndC);
                                                             } else {
                                                                 orC.add(getFieldCondition(ftype, s, value));
                                                             }
                                                         }
                                                         //Add the where clause
                                                         soqlB.wherex(orC);
                                                     } else {
                                                         BT_SoqlAndCondition andC = new BT_SoqlAndCondition();
                                                         
                                                         //Loop through the list of fields to validate and add them to the condition
                                                         for (String s : queryFields) {
                                                             if (validateFields) {
                                                                 Schema.SObjectField sof = gf.get(s);
                                                                 if (sof == null) {
                                                                     throw new BT_ApplicationException(String.format(system.Label.Field_Not_Valid_For_Object,new String[]{s, obj}));
                                                                   //  return null;
                                                                 }
                                                             }
                                                             
                                                             //Get field type
                                                             Schema.DisplayType ftype = null;
                                                             Schema.SObjectField sof = gf.get(s);
                                                             if (sof != null) {
                                                                 Schema.DescribeFieldResult dfr = sof.getDescribe();
                                                                 ftype = dfr.getType();
                                                             }
                                                             
                                                             String value = queryFieldNameValue.get(s);
                                                             
                                                             List<String> andMultiValues = new List<String>();
                                                             List<String> orMultiValues = new List<String>();
                                                             if(value != null){
                                                                 andMultiValues = BT_Utils.tokenizeStringWithSeparator(value,',');
                                                                 orMultiValues = BT_Utils.tokenizeStringWithSeparator(value,';');
                                                             }
                                                             if(orMultiValues.size() > 1){
                                                                 BT_SoqlOrCondition nestedOrC = new BT_SoqlOrCondition();
                                                                 for (String v : orMultiValues) {
                                                                     nestedOrC.add(getFieldCondition(ftype, s, v));
                                                                 }
                                                                 andC.add(nestedOrC);
                                                             } else if(andMultiValues.size() > 1){
                                                                 BT_SoqlAndCondition nestedAndC = new BT_SoqlAndCondition();
                                                                 for (String v : andMultiValues) {
                                                                     nestedAndC.add(getFieldCondition(ftype, s, v));
                                                                 }
                                                                 andC.add(nestedAndC);
                                                             } else {
                                                                 andC.add(getFieldCondition(ftype, s, value));
                                                             }
                                                         }
                                                         //Add the where clause
                                                         soqlB.wherex(andC);
                                                     }
                                                 }
                                             }
                                             if (includeObjectwithIDs != null && !includeObjectwithIDs.isEmpty()) {
                                                 soqlB.wherex(new BT_SoqlSetCondition('id',BT_SoqlBuilder.Operator.INX,includeObjectwithIDs));
                                             }
                                             
                                             String soql = soqlB.toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators());
                                             
                                             return soql;
                                         }
    
    /*
*   Purpose:    Get count of objects grouped by specified groupByField. 
The result will be aggregate result with two aliased fields fieldValue, fieldCount). AggregateResult[] groupedResults e.g. [(status1, 20), (status2, 20)]
*   Parameters: obj - object name
groupByField - group by field name
queryFieldNameValue - (name, value) pairs for query. value can have csv list for multiple checks
conditionType - if there are multiple fields to query, use 'or' or 'and' condition
orderbyField - order result by this field
*   UnitTests:  
*/
    public static sObject[] getObjectGroupByCount(String obj, 
                                                  String groupByField, 
                                                  Map<String, String> queryFieldNameValue,
                                                  String conditionType, 
                                                  String groupByQuery) {
                                                      String soql;
                                                      
                                                      //If tree node configuration group by qery string is not an empty then we use that query to fetch group by records.
                                                      //Group By query will possible only if filter parameters will only on parent objects, for example
                                                      //To get the source type we grup by the Name of "Source type" and we need to get all source types from the salesforce org
                                                      //so we directly pass Group By Query as "Select Count(id) fieldCount, Name fieldValue from Source_Type__c Group By Name Order By Name"
                                                      if(groupByQuery == null){         
                                                          //Check to see if the object passed is valid
                                                          Schema.SObjectType sot = BT_Utils.getObjectTypeFromTypeName(obj);
                                                          if (sot == null) {
                                                              throw new BT_ApplicationException(String.format(system.Label.Object_Name_Not_Valid,new String[]{obj}));
                                                           //   return null;
                                                          }       
                                                          //Get a map of all fields in the object
                                                          Map<String, Schema.SObjectField> gf = sot.getDescribe().fields.getMap();
                                                          
                                                          BT_SoqlBuilder soqlB = new BT_SoqlBuilder()
                                                              .selectx(groupByField + ' fieldValue')  // uses fieldValue
                                                              .selectx('Count(id) fieldCount')
                                                              .fromx(obj);
                                                          
                                                          //Add the where statement. If no additional fields were sent, it is easy
                                                          BT_SoqlCondition whereCondition;
                                                          if (queryFieldNameValue != null) {
                                                              Set<String> queryFields = queryFieldNameValue.keySet(); 
                                                              if (queryFields != null && !queryFields.isEmpty()) {
                                                                  //Create the condition for the soql
                                                                  if(conditionType == 'or') {
                                                                      BT_SoqlOrCondition orC = new BT_SoqlOrCondition();
                                                                      
                                                                      //Loop through the list of fields to validate and add them to the condition
                                                                      for (String s : queryFields) {
                                                                          //Get field type
                                                                          Schema.DisplayType ftype = null;
                                                                          Schema.SObjectField sof = gf.get(s);
                                                                          if (sof != null) {
                                                                              Schema.DescribeFieldResult dfr = sof.getDescribe();
                                                                              ftype = dfr.getType();
                                                                          }
                                                                          
                                                                          String value = queryFieldNameValue.get(s);                        
                                                                          
                                                                          List<String> andMultiValues = new List<String>();
                                                                          List<String> orMultiValues = new List<String>();
                                                                          if(value != null){
                                                                              andMultiValues = BT_Utils.tokenizeStringWithSeparator(value,',');
                                                                              orMultiValues = BT_Utils.tokenizeStringWithSeparator(value,';');
                                                                          }
                                                                          
                                                                          if(orMultiValues.size() > 1){
                                                                              BT_SoqlOrCondition nestedOrC = new BT_SoqlOrCondition();
                                                                              for (String v : orMultiValues) {
                                                                                  nestedOrC.add(getFieldCondition(ftype, s, v));
                                                                              }
                                                                              orC.add(nestedOrC);
                                                                          } else if(andMultiValues.size() > 1){
                                                                              BT_SoqlAndCondition nestedAndC = new BT_SoqlAndCondition();
                                                                              for (String v : orMultiValues) {
                                                                                  nestedAndC.add(getFieldCondition(ftype, s, v));
                                                                              }
                                                                              orC.add(nestedAndC);
                                                                          } else {
                                                                              orC.add(getFieldCondition(ftype, s, value));
                                                                          }
                                                                      }
                                                                      //Add the where clause
                                                                      whereCondition = orC;
                                                                  } else {
                                                                      BT_SoqlAndCondition andC = new BT_SoqlAndCondition();
                                                                      
                                                                      //Loop through the list of fields to validate and add them to the condition
                                                                      for (String s : queryFields) {
                                                                          //Get field type
                                                                          Schema.DisplayType ftype = null;
                                                                          Schema.SObjectField sof = gf.get(s);
                                                                          if (sof != null) {
                                                                              Schema.DescribeFieldResult dfr = sof.getDescribe();
                                                                              ftype = dfr.getType();
                                                                          }
                                                                          
                                                                          String value = queryFieldNameValue.get(s);                                                                       
                                                                          
                                                                          List<String> andMultiValues = new List<String>();
                                                                          List<String> orMultiValues = new List<String>();
                                                                          if(value != null){
                                                                              andMultiValues = BT_Utils.tokenizeStringWithSeparator(value,',');
                                                                              orMultiValues = BT_Utils.tokenizeStringWithSeparator(value,';');
                                                                          }
                                                                          
                                                                          if(orMultiValues.size() > 1){
                                                                              BT_SoqlOrCondition nestedOrC = new BT_SoqlOrCondition();
                                                                              for (String v : orMultiValues) {
                                                                                  nestedOrC.add(getFieldCondition(ftype, s, v));
                                                                              }
                                                                              andC.add(nestedOrC);
                                                                          } else if(andMultiValues.size() > 1){
                                                                              BT_SoqlAndCondition nestedAndC = new BT_SoqlAndCondition();
                                                                              for (String v : orMultiValues) {
                                                                                  nestedAndC.add(getFieldCondition(ftype, s, v));
                                                                              }
                                                                              andC.add(nestedAndC);
                                                                          } else {
                                                                              andC.add(getFieldCondition(ftype, s, value));
                                                                          }
                                                                      }
                                                                      //Add the where clause
                                                                      whereCondition = andC;
                                                                  }
                                                              }
                                                          }
                                                          
                                                          //Based on system property configuration, add a USER filter
                                                          BT_SoqlCondition otherCondition;
                                                          if(sot.getDescribe().getName() == 'User'){
                                                          }
                                                          
                                                          //Build an AND condition with the WHERE condition and the USER filter
                                                          if(whereCondition != null && otherCondition != null){
                                                              BT_SoqlAndCondition updatedWhereCondition = new BT_SoqlAndCondition();
                                                              updatedWhereCondition.add(whereCondition);
                                                              updatedWhereCondition.add(otherCondition);
                                                              soqlB.wherex(updatedWhereCondition);
                                                          } else if(whereCondition != null){
                                                              soqlB.wherex(whereCondition);
                                                          } else if(otherCondition != null){
                                                              soqlB.wherex(otherCondition);
                                                          }
                                                          
                                                          soql = soqlB.toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators());
                                                          
                                                          //soqlBuilder does not support group by, add our groupby manually
                                                          soql = soql + ' Group By ' + groupByField;
                                                      } else {
                                                          soql = groupByQuery;
                                                      }
                                                      
                                                      List<sObject> L = new List<sObject>();
                                                      try {
                                                          L = Database.query(soql);
                                                      }
                                                      catch (QueryException e) {
                                                          throw e;
                                                        //  return null;
                                                      }
                                                      return L;
                                                  }
    public static sObject[] getObjectGroupByCount(String obj, 
                                                  String groupByField, 
                                                  List<BT_SoqlCondition> fieldConditions,
                                                  String conditionType) {
                                                      
                                                      //Check to see if the object passed is valid
                                                      Schema.SObjectType sot = BT_Utils.getObjectTypeFromTypeName(obj);
                                                      if (sot == null) {
                                                          throw new BT_ApplicationException(String.format(system.Label.Object_Name_Not_Valid,new String[]{obj}));
                                                      //    return null;
                                                      }       
                                                      //Get a map of all fields in the object
                                                      Map<String, Schema.SObjectField> gf = sot.getDescribe().fields.getMap();
                                                      
                                                      BT_SoqlBuilder soqlB = new BT_SoqlBuilder()
                                                          .selectx(groupByField + ' fieldValue')  // uses fieldValue
                                                          .selectx('Count(id) fieldCount')
                                                          .fromx(obj);
                                                      
                                                      //Add the where statement. If no additional fields were sent, it is easy
                                                      if (fieldConditions != null) {
                                                          //Create the condition for the soql
                                                          if (conditionType == 'or') {
                                                              BT_SoqlOrCondition orC = new BT_SoqlOrCondition();
                                                              for(BT_SoqlCondition fieldCondition : fieldConditions){
                                                                  orC.add(fieldCondition);
                                                              }
                                                              //Add the where clause
                                                              soqlB.wherex(orC);
                                                          } else {
                                                              BT_SoqlAndCondition andC = new BT_SoqlAndCondition();
                                                              for(BT_SoqlCondition fieldCondition : fieldConditions){
                                                                  andC.add(fieldCondition);
                                                              }
                                                              //Add the where clause
                                                              soqlB.wherex(andC);
                                                          }
                                                      }
                                                      String soql = soqlB.toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators());
                                                      
                                                      //soqlBuilder does not support group by, add our groupby manually
                                                       soql = soql + ' Group By ' + groupByField;
                                                      
                                                      List<sObject> L = new List<sObject>();
                                                      try {
                                                          L = Database.query(soql);
                                                      }
                                                      catch (QueryException e) {
                                                          throw e;
                                                        //  return null;
                                                      }
                                                      return L;
                                                  }
    /*
*   Purpose:    Returns the all objects of the specified type
*   Parameters: objectType            
maxLimit
fields
orderBy
*   UnitTests:  
*/
    
    public static List<sObject> getAllObjects(String objType, List<String> fields, Integer maxLimit, String orderBy){
        String soql = 'SELECT id ';
        if(fields != null){
            for(String field : fields){
                if(field != 'id'){
                    soql = soql + ', ' + field;
                }
            }
        }
        soql = soql + ' FROM ' + objType + ' Order By ' + orderBy + ' LIMIT ' + maxLimit;
        
        List<sObject> L = new List<sObject>();
        try {
            L = Database.query(soql);
        }
        catch (QueryException e) {
            throw e;
           // return null;
        }
        return L;
    }           
    
    
    /*
*   Purpose:    Returns the child of an object using children__r, if there are any
*   Parameters: objectType            
id
fields
*   UnitTests:  
*/
    public static List<sObject> getChildren(String objectType, Id id, List<String> fields){
        
        if(objectType != null && objectType.trim() != '' && Schema.getGlobalDescribe().get(objectType) != null){
            try {
                String soql = 'SELECT id ,(SELECT id';
                if(fields != null){
                    for(String field : fields){
                        if(field != 'id'){
                            soql = soql + ', ' + field;
                        }
                    }
                }
                soql = soql + ' FROM ' + objectType + '.Children__r order by name) FROM ' + objectType + ' WHERE id = :id';
                sObject obj = Database.query(soql);
                
                return (List<sObject>)obj.getSObjects('Children__r');
                
            } catch (Exception e) {
                // Could be that "Children" relationship is not defined for this object.
                return null;
            }
        }
        return null;
    }
}