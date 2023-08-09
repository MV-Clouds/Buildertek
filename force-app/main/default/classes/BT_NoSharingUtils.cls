/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Utils Class: BT_NoSharingUtils
* Created by Sagar
*
* All no sharing utility methods

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_NoSharingUtils {
    /**************************************************************************
       Purpose: Creating share record for files 
       Parameters: List of File Share records
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    public static void createFileShares(List<File__Share> newShares){
       
       insert newShares;
        
    }
    
    /**************************************************************************
       Purpose: Delete share recid for any object
       Parameters: List of Share records
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    public static void deleteShares(List<SObject> lstShares) {
        DMLManager.deleteAsUser(lstShares);
    }
    
    /**************************************************************************
       Purpose: Update records any object
       Parameters: List of records
       Returns: 
       Throws [Exceptions]:  
    ****************************************************************************/
    public static void updateSobjects(List<SObject> lstSobjects) {
        update lstSobjects;
    }
    
    /**************************************************************************
       Purpose: delete records any object
       Parameters: List of records
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    public static void deleteSobjects(List<SObject> lstSobjects) {
        DMLManager.deleteAsUser(lstSobjects);
    }
    
    /**********************************************************************************************************
       Purpose: This method will be used to retrieve the list of sobjects using query string and bypassing the security setting for object. 
       Parameters:  queryString - Query string to retirive objects.
       Returns:     List of sobjects
       Throws [Exceptions]: 
    **********************************************************************************************************/
    public static list<sobject> getObjectsUsingQueryString(String queryString){
        return Database.query(queryString);
    }
    
    /**********************************************************************************************************
       Purpose: This method will be used to retrieve standard set controller using query string and bypassing the security setting for object. 
       Parameters:  queryString - Query string to standard set controller query locator.
       Returns:     StandardSetController
       Throws [Exceptions]: 
    **********************************************************************************************************/
    public static ApexPages.StandardSetController getStandardSetControllerUsingQueryString(String queryString){
        return new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
    }
    
    /**********************************************************************************************************
       Purpose: This method will be used to retrieve the Count of sobjects rescords using query string and bypassing the security setting for object. 
       Parameters:  queryString - Query string to retirive Record count.
       Returns:     Integer (Count)
       Throws [Exceptions]: 
    **********************************************************************************************************/
    public static Integer getRecordCountUsingQueryString(String queryString){
        return Database.countQuery(queryString);
    }
    
    /**********************************************************************************************************
       Purpose: This method will be used to insert the list of sobjects, bypassing the security setting for object. 
       Parameters:  recordsToInsert - List of sobject you want to insert.
                    allOrNone - True -  If you want all all none recotrds to be inserted.
       Returns:     List of Save Result
       Throws [Exceptions]: 
    **********************************************************************************************************/
    public static List<Database.SaveResult> doInsert(List<sObject> recordsToInsert, Boolean allOrNone) {
        return Database.insert(recordsToInsert, allOrNone);
    }
    
    /**********************************************************************************************************
       Purpose: This method will be used to update the list of sobjects, bypassing the security setting for object. 
       Parameters:  recordsToUpdate - List of sobject you want to update.
                    allOrNone - True -  If you want all all none recotrds to be updated.
       Returns:     List of Save Result
       Throws [Exceptions]: 
    **********************************************************************************************************/
    public static List<Database.SaveResult> doUpdate(List<sObject> recordsToUpdate, Boolean allOrNone) {
        return Database.update(recordsToUpdate, allOrNone);
    }
    
    /**********************************************************************************************************
       Purpose: This method will be used to upsert the list of sobjects, bypassing the security setting for object. 
       Parameters:  recordsToUpsert - List of sobject you want to upsert.
       Returns:     
       Throws [Exceptions]: 
    **********************************************************************************************************/
    public static void doUpsert(List<sObject> recordsToUpsert) {
       upsert recordsToUpsert;
    }
    
    /**********************************************************************************************************
       Purpose: This method will be used to delete the list of sobjects, bypassing the security setting for object. 
       Parameters:  recordsToDelete - List of sobject you want to delte.
                    allOrNone - True -  If you want all all none recotrds to be deleted.
       Returns:     List of Delete Result
       Throws [Exceptions]: 
    **********************************************************************************************************/
    public static List<Database.DeleteResult> doDelete(List<sObject> recordsToDelete, Boolean allOrNone) {
        DMLManager.deleteAsUser(recordsToDelete);
        return null;
        /*
            This query looks for Delete operations that are performed without checking for isDeletable().
            This may be a false positive if your code accesses only objects whose security is managed by your app and not the admin (for example OAuth states). 
            It may also be a false positive if checks are performed outside of the dataflow (automatically in a visualforce inputfield tag or manually in a constructor), 
            or if this is an enterprise object or other object whose permissions are not set by the admin.
        */
        //return Database.delete(recordsToDelete, allOrNone);
    }
}