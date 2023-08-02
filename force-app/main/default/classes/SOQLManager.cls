/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: SOQLManager
* Created by Sagar: 15/09/2017
*
* - Used to FLS for soql query.

* - Modifications:
* - Sagar, 15/09/2017 – Initial Development
************************************************************************** */
public with sharing class SOQLManager {
    // Items in the following set must be entered in lower case
    private static Set<String> exceptionValues = new Set<String> {'id','isdeleted','createddate','systemmodstamp','lastmodifiedbyid','createdbyid','lastmodifieddate'};

    // Restricted fields by object type
    private static Map<SObjectType,List<String>> cachedRestrictedFields = new Map<SObjectType,List<String>>();
    
    // Custom SOQL Exception Classe
    public virtual class SOQLManagerException extends Exception{
        public SObjectType objType {get; private set;}
    }
    
    
    // Custom FLS Exception Classe 
    public class FLSException extends SOQLManagerException{
        public SObjectField field{get; private set;}    
        public FLSException(SObjectType objType, SObjectField field){
            this('Access Denied: for ' + objType + '.' + field);
            this.objType = objType;
            this.field = field;
        }
    }
    
    /********************************************************************
    Purpose: Set the cached map for restricted fields by sobject type.
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/  
    private static void ensureRestrictedFields(SObjectType objType){
        if(!cachedRestrictedFields.containsKey(objType)){
            DescribeSObjectResult describeObject = objType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = describeObject.fields.getMap();
            List<String> restrictedFields = new List<String>();
            for(String nm : objectFields.keyset()){
                if(!exceptionValues.contains(nm.toLowerCase())){
                    DescribeFieldResult fr = objectFields.get(nm).getDescribe();
                    System.debug('***'+fr.getName()+'-->'+fr.isAccessible());
                    if(fr.isCustom() && !fr.isAccessible()){
                        restrictedFields.add(fr.getLocalName());
                    }
                }
            }
            cachedRestrictedFields.put(objType,restrictedFields);
        }
    }
    
    
    /********************************************************************
    Purpose: Check if user has access for all fields
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/  
    public static void checkFieldAccess(SObjectType objType, List<String> fields){
        // Do field retriction
        ensureRestrictedFields(objType);
        
        // Get restricted fields
        List<String> restrictedFields = cachedRestrictedFields.get(objType);
        
        // Save ourselves a trip through the loop below if there are no restricted fields
        if(restrictedFields == null || restrictedFields.isEmpty()){
            return;
        }
        
        // Set of fields
        Set<String> fieldsSet = new Set<String>();
        fieldsSet.addAll(fields);
        
        // If any of the restricted values are present and have changed in the soql candidate object, throw an exception
        for(String fieldName : restrictedFields){
            if(fieldsSet.contains(fieldName)){
                throw new FLSException(objType, objType.getDescribe().fields.getMap().get(fieldName));
            }
        }    
    }
    
}