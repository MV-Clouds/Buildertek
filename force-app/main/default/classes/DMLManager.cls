/**
* Copyright (c), 2014, Patron Holdings LLC
* All rights reserved.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
*  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
*  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
*  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
*  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public without sharing class DMLManager {
	
	public static Boolean RUNNING_DML_MANAGER_TEST = false;
	
    // Items in the following set must be entered in lower case
    private static Set<String> exceptionValues = new Set<String> {'id','isdeleted','createddate','systemmodstamp','lastmodifiedbyid','createdbyid','lastmodifieddate'};

    // Restricted fields for operation by object type
    private static Map<Operation,Map<SObjectType,List<String>>> cachedRestrictedFields = new Map<Operation,Map<SObjectType,List<String>>>();
    
    // Allowed Operations
    public enum Operation {OP_INSERT,OP_UPDATE,OP_DELETE,OP_UPSERT}
    
    // Custom DML Exception Classe
    public virtual class DMLManagerException extends Exception{
        public SObjectType objType {get; private set;}
        public Operation op{get; private set;}
    }
	
	// Custom CRUD Exception Classe
    public class CRUDException extends DMLManagerException{
        public CRUDException(SObjectType objType, Operation op){
            this('Access Denied: ' + op + ' on ' + objType);
            this.objType = objType;
            this.op = op;
        }
    }
	
	// Custom FLS Exception Classe 
    public class FLSException extends DMLManagerException{
        public SObjectField field{get; private set;}    
        public FLSException(SObjectType objType, SObjectField field, Operation op){
            this('Access Denied: ' + op + ' on ' + objType + '.' + field);
            this.objType = objType;
            this.op = op;
            this.field = field;
        }
    }
    
    // CRUD and FLS-safe DML operations. These honor the CRUD and FLS permissions of the running user
    public static void insertAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_INSERT);}
    public static void updateAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_UPDATE);}
    public static void upsertAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_UPSERT);}
    public static void deleteAsUser(sObject obj){performDMLOperation(new List<sObject>{obj},Operation.OP_DELETE);}
    
    public static void insertAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_INSERT);}
    public static void updateAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_UPDATE);}
    public static void upsertAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_UPSERT);}
    public static void deleteAsUser(List<SObject> objList){performDMLOperation(objList,Operation.OP_DELETE);}
    
    // Pass-thru methods to raw DML operations. Use these sparingly and only with good reason, since the DML operations are not CRUD/FLS safe
    public static void insertAsSystem(sObject obj){ insert obj; }
    public static void updateAsSystem(sObject obj){ update obj; }
    public static void upsertAsSystem(sObject obj){ upsert obj; }
    public static void deleteAsSystem(sObject obj){ delete obj; }
    
    public static void insertAsSystem(List<SObject> objList){ insert objList; }
    public static void updateAsSystem(List<SObject> objList){ update objList; }
    public static void upsertAsSystem(List<SObject> objList){ upsert objList; }
    public static void deleteAsSystem(List<SObject> objList){ delete objList; }
    
    /********************************************************************
    Purpose: Perform DML oprations. These honor the CRUD and FLS permissions of the running user
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/    
    private static void performDMLOperation(List<SObject> objList, Operation dmlOperation){
    	
    	if(!(Test.isRunningTest() && !RUNNING_DML_MANAGER_TEST)){
    		
	        // Group sobjects by their object types. And also set the map for restricted fields by sobject type.
	        Map<SObjectType,List<Id>> objTypeMap = analyzeDMLCollection(objList, dmlOperation);
			// Check CRUD permissions for each object type
	        checkCRUDPermission(objTypeMap.keySet(), dmlOperation);
			
			// Check for permission
	        if(dmlOperation == Operation.OP_INSERT){
	            for(SObject obj : objList){
	                checkCreateAction(obj);
	            }
	        } else if (dmlOperation == Operation.OP_UPDATE || dmlOperation == Operation.OP_UPSERT){
	            for(SObject obj : objList){
	                if(obj.id != null){
	                    checkUpdateAction(obj);
	                } else {
	                    checkCreateAction(obj);
	                }
	            } 
	        }
        
    	}
          // If no errors have been thrown to this point, execute the dml operation.
        if(dmlOperation == Operation.OP_INSERT){
            insert objList;
        } else if(dmlOperation == Operation.OP_UPDATE){
            update objList;
        } else if(dmlOperation == Operation.OP_UPSERT){
            upsertCollection(objList);
        } else if(dmlOperation == Operation.OP_DELETE){
            delete objList;
        }
    }
    
    
    private static void upsertCollection(List<SObject> objList){
        // This is to deal with a call to upsertAsUser with a singular object.
        // Since we wrap that into a List<SObject> (which can't be passed into an upsert)
        // we unpack it and upsert the object individually.
        if(objList.size() == 1){
            upsert objList.get(0);
        } else {
            upsert objList;
        }
    }
    
    /********************************************************************
    Purpose: Get the all fields included in sobject
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/  
    private static Map<String,Object> getFieldMapFromExistingSObject(SObject obj){
        // Get actual fields present in object.  This serialization technique removes implicit nulls.
        String s = JSON.serialize(obj);
        Map<String,Object> fieldsMap = (Map<String,Object>) JSON.deserializeUntyped(s);
        fieldsMap.remove('attributes');
        return fieldsMap;       
    }
    
    /********************************************************************
    Purpose: Check if user has insert access
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/  
    private static void checkCreateAction(SObject obj){
        List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_INSERT).get(obj.getSObjectType());
        // Save ourselves a trip through the loop below if there are no restricted fields
        if(restrictedFields == null || restrictedFields.isEmpty()){
            return;
        }
        Map<String,Object> fieldsMap = getFieldMapFromExistingSObject(obj);
        // If any restricted fields are present, throw an exception
        for(String fieldName : restrictedFields){
            if(fieldsMap.get(fieldName) != null){ // if any of the restricted fields are present in the candidate, throw an exception
                throw new FLSException(obj.getSObjectType(),obj.getSObjectType().getDescribe().fields.getMap().get(fieldName),Operation.OP_INSERT);
            }
        }  
    }

	/********************************************************************
    Purpose: Check if user has update access
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/  
    private static void checkUpdateAction(SObject obj){
        List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_UPDATE).get(obj.getSObjectType());
        // Save ourselves a trip through the loop below if there are no restricted fields
        if(restrictedFields == null || restrictedFields.isEmpty()){
            return;
        }
        
        Map<String,Object> fieldsMap = getFieldMapFromExistingSObject(obj);
        // If any of the restricted values are present and have changed in the dml candidate object, throw an exception
        for(String fieldName : restrictedFields){
            if(fieldsMap.get(fieldName) != null){
                throw new FLSException(obj.getSObjectType(),obj.getSObjectType().getDescribe().fields.getMap().get(fieldName),Operation.OP_UPDATE);
            }
        }    
    }

	/********************************************************************
    Purpose: Check CRUD permissions for the current user on the object
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/          
    private static void checkCRUDPermission(Set<SObjectType> objTypeList, Operation dmlOperation){
        for(SObjectType objType : objTypeList){
            DescribeSObjectResult describeObject = objType.getDescribe();
            if((dmlOperation == Operation.OP_INSERT && !describeObject.isCreateable()) ||
               	(dmlOperation == Operation.OP_UPDATE && !describeObject.isUpdateable()) ||
               	(dmlOperation == Operation.OP_DELETE && !describeObject.isDeletable()) ||
               	(dmlOperation == Operation.OP_UPSERT && !(describeObject.isCreateable() && describeObject.isUpdateable()))) {
            	throw new CRUDException(objType,dmlOperation);
            }
        }
    }
    
    /********************************************************************
    Purpose: Get a Map of all the object types in the dml request and the list of fields for each that the current user cannot update, based on FLS security settings
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/  
    private static Map<SObjectType,List<Id>> analyzeDMLCollection(List<SObject> objList, Operation dmlOperation){
        Map<SObjectType,List<Id>> result = new Map<SObjectType,List<Id>>();
        for(SObject obj : objList){
            ensureRestrictedFieldsEntry(obj, dmlOperation);
            List<Id> seenIds = result.get(obj.getSObjectType());
            if(seenIds == null){
                seenIds = new List<Id>();
                result.put(obj.getSObjectType(),seenIds);
            }
            if(obj.Id == null){
                continue;
            }   
            seenIds.add(obj.Id);
        }
        return result;
    }
    
    /********************************************************************
    Purpose: Set the cached map for restricted fields by sobject type.
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/  
    private static void ensureRestrictedFieldsEntry(SObject obj, Operation dmlOperation){
        if(dmlOperation == Operation.OP_UPSERT){
            ensureRestrictedFields(obj,Operation.OP_INSERT);
            ensureRestrictedFields(obj,Operation.OP_UPDATE);
        }
        else{
            ensureRestrictedFields(obj,dmlOperation);
        }
    }
    
    /********************************************************************
    Purpose: Set the cached map for restricted fields by sobject type.
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/  
    private static void ensureRestrictedFields(SObject obj, Operation dmlOperation){
        Map<SObjectType,List<String>> operationRestrictedFields = cachedRestrictedFields.get(dmlOperation);
        if(operationRestrictedFields == null){
            operationRestrictedFields = new Map<SObjectType,List<String>>();
            cachedRestrictedFields.put(dmlOperation,operationRestrictedFields);
        }
        
        if(!operationRestrictedFields.containsKey(obj.getSObjectType())){
            DescribeSObjectResult describeObject = obj.getSObjectType().getDescribe();
            Map<String, Schema.SObjectField> objectFields = describeObject.fields.getMap();
            List<String> restrictedFields = new List<String>();
            for(String nm : objectFields.keyset()){
                if(!exceptionValues.contains(nm.toLowerCase())){
                    DescribeFieldResult fr = objectFields.get(nm).getDescribe();
                    if(fr.isPermissionable() && (!fr.isCalculated()) && ((dmlOperation == Operation.OP_INSERT && !fr.isCreateable()) || (dmlOperation == Operation.OP_UPDATE && !fr.isUpdateable()))){
                        restrictedFields.add(fr.getName());
                    }
                }
            }
            operationRestrictedFields.put(obj.getSObjectType(),restrictedFields);
        }
    }   
}