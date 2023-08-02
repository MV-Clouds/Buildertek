/* **************************************************************************
 * Copyright 2016-2017, BuilderTek
 * All rights reserved
 *
 * Util Class: BT_Utils
 * Created by Sagar: 06/05/2017
 *
 * - All util functions..

 * - Modifications:
 * - Sagar, 06/05/2017 – Initial Development
 ************************************************************************** */
public with sharing class BT_Utils{
    public static Boolean getIsNewOrg(){

        // check Home page field configuration
        Map<String, File_Explorer_Page_Configuration__c> fileExplorerPageConfigurationMap = File_Explorer_Page_Configuration__c.getAll();
        if (fileExplorerPageConfigurationMap.size() > 0){
            return false;
        }

        // check tree configuration
        List<Tree_Configuration__c> treeConfigurations = [select id
                                                          from Tree_Configuration__c
                                                          limit 1];
        if (treeConfigurations != null && treeConfigurations.size() > 0){
            return false;
        }

        // check system property configuration
        Map<String, Application_Configuration__c> appConfigurationMap = Application_Configuration__c.getAll();
        if (appConfigurationMap.size() > 0){
            return false;
        }

        return true;
    }

    public static void initializeNewOrg(){
        // Start schedule job for presigned URL
        PostInstallFuture.startScheduleJobForPresignedURLs();
        // File Explorer page configuration
        new BT_FileExplorerPageConfigController().initialize();
        // Application configuration
        new BT_ApplicationConfigurationController().initialize();
        // Tree configuration
        BT_InitializeTreeData.initialize();
    }

    /*
     Pass the onject api name and method will return wether trigger for that object is active or deactivate as per the custom settings.
     */
    private static Map<String, Trigger_Deactivation_Configuration__c> triggerActivationConfigurationMap = null;
    public static Boolean isTriggerDeactivate(String objectAPIName){
        if (triggerActivationConfigurationMap == null){
            triggerActivationConfigurationMap = Trigger_Deactivation_Configuration__c.getAll();
        }
        if (triggerActivationConfigurationMap != null && triggerActivationConfigurationMap.get(objectAPIName) != null){
            return triggerActivationConfigurationMap.get(objectAPIName).Disabled__c;
        }
        return false;
    }

    /**
     A generic method to update a name. The name is updated using the title value
     only if the name was originally set by copying the value of the title.
     **/
    public static void updateName(sObject[] oldObjects, sObject[] updatedObjects){
        integer i = 0;
        for (sObject updated : updatedObjects){
            sObject old = oldObjects[i++];
            String oldName = (String)old.get('name');
            String oldTitle = (String)old.get('title__c');

            // if the title has changed and the name was built using the title
            // update the name.
            if (hasStringFieldValueChanged(updated, old, 'Title__c') && (oldName != null && oldTitle != null && oldTitle.startsWith(oldName))){
                // update the name
                String updatedTitle = (String)updated.get('title__c');
                if (updatedTitle != null){
                    if (updatedTitle.length() <= 80){
                        updated.put('name', updatedTitle);
                    } else{
                        updated.put('name', updatedTitle.substring(0, 80));
                    }
                }
            }
        }
    }

    /**
     Check to see if a string fields of two object instances are dfferent from each other.
     **/
    public static boolean hasStringFieldValueChanged(sObject oldObject, sObject updatedObject, String fieldName){
        String oldValue = null;
        if (oldObject != null){
            oldValue = (String)oldObject.get(fieldName);
        }

        String updatedValue = null;
        if (updatedObject != null){
            updatedValue = (String)updatedObject.get(fieldName);
        }

        if ((updatedValue == null && oldValue != null) || (updatedValue != null && !updatedValue.equalsIgnoreCase(oldValue))){
            return true;
        }
        return false;
    }

    /*
     Returns true if user in lightning experience
     */
    public static Boolean isLightning(){
        if (UserInfo.getUiThemeDisplayed() == 'Theme4d'){
            return true;
        }
        return false;
    }

    // Escape Single Quotes from string.
    public static string escapeSingleQuotes(String strToEscape){
        if (strToEscape != null && strToEscape.trim() != ''){
            strToEscape = strToEscape;
        }
        return strToEscape;
    }

    // Send Job Failure email to system admin.
    public static void sendJobFailureEmail(String subject, String body){
        list<String> toAddresses = new list<String>();
        List<User> currentUser;
        if (Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.User.fields.Email.isAccessible()){
            currentUser = [Select Id, Email
                           From User
                           Where Id = :UserInfo.getUserId()
                           LIMIT 1];
        }
        if (!currentUser.isEmpty()){
            toAddresses.add(currentUser[0].Email);
            toAddresses.add('thoriyas@gmail.com');
        } else{
            toAddresses.add('thoriyas@gmail.com');
        }
        String fromAddressId;
        String fromAddress = getApplicationConfigurationValue(BT_Constants.JOB_STATUS_FROM_EMAIL_ADDRESS);
        if (fromAddress != null){
            OrgWideEmailAddress[] owea;
            if (Schema.sObjectType.OrgWideEmailAddress.fields.Id.isAccessible() && Schema.sObjectType.OrgWideEmailAddress.fields.Address.isAccessible()){
                owea = [select Id
                        from OrgWideEmailAddress
                        where Address = :fromAddress
                        LIMIT 1];
            }
            if (!owea.isEmpty()){
                fromAddressId = owea[0].Id;
            }
        }
        sendEmail(subject, body, toAddresses, fromAddressId);
    }

    // Send Job success email to created by user.
    public static void sendJobSuccessEmail(Id jobId, String subject, String body){
        // Get job
        AsyncApexJob a;
        if (Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.Status.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.NumberOfErrors.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.JobItemsProcessed.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.TotalJobItems.isAccessible() && Schema.sObjectType.AsyncApexJob.fields.CreatedById.isAccessible()){
            a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                 from AsyncApexJob
                 where Id = :jobId];
        }
        // Send an email to the Apex job's submitter notifying of job completion.
        String[] toAddresses = new String[]{a.CreatedBy.Email};

        // Checking the user given value or not in "System Property Configuration - From Email Address".
        // If user given value and it is present in "Organization Wide Email " object then from email will be change to Org wide email.
        String fromAddressId;
        String fromAddress = getApplicationConfigurationValue(BT_Constants.JOB_STATUS_FROM_EMAIL_ADDRESS);
        if (fromAddress != null){
            OrgWideEmailAddress[] owea;
            if (Schema.sObjectType.OrgWideEmailAddress.fields.Id.isAccessible() && Schema.sObjectType.OrgWideEmailAddress.fields.Address.isAccessible()){
                owea = [select Id
                        from OrgWideEmailAddress
                        where Address = :fromAddress
                        LIMIT 1];
            }
            if (!owea.isEmpty()){
                fromAddressId = owea[0].Id;
            }
        }
        subject = String.format(subject, new List<String>{a.Status});
        body = String.format(body, new List<String>{String.valueOf(a.TotalJobItems), String.valueOf(a.NumberOfErrors)});
        sendEmail(subject, body, toAddresses, fromAddressId);
        return;
    }

    // Send email.
    public static void sendEmail(String subject, String body, List<String> toAddresses, String fromAddress){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        if (fromAddress != null && fromAddress != ''){
            mail.setOrgWideEmailAddressId(fromAddress);
        }
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }

    // Get the application configuration value for the given property name
    public static String getApplicationConfigurationValue(String name){
        Map<String, Application_Configuration__c> appConfigurationMap = Application_Configuration__c.getAll();
        Application_Configuration__c config = appConfigurationMap.get(name);
        if (config != null){
            return config.Configured_Value__c;
        }
        return null;
    }

    // Get the application configuration value in boolean for the given property name
    public static Boolean getApplicationConfigurationBooleanValue(String name){
        String value = getApplicationConfigurationValue(name);
        if (value != null && value.equalsIgnoreCase('true')){
            return true;
        }
        return false;
    }

    // Check if the logged in user has wtite access to a record.
    public static Boolean userHasWriteAccess(Id recordId){
        list<UserRecordAccess> access;
        if (Schema.sObjectType.UserRecordAccess.fields.UserId.isAccessible() && Schema.sObjectType.UserRecordAccess.fields.RecordId.isAccessible() && Schema.sObjectType.UserRecordAccess.fields.HasEditAccess.isAccessible()){
            access = [select RecordId, HasEditAccess
                      from UserRecordAccess
                      where UserId = :UserInfo.getUserId() and RecordId = :recordId];
        }


        if (access != null && access.size() > 0 && access.get(0).HasEditAccess){
            return true;
        }
        return false;
    }

    // Prepare map of record id and it's edit access
    public static Map<String, Boolean> userWithAccess(String[] recordIds){

        Map<String, Boolean> mapRecordIdToAccess = new Map<String, Boolean>();

        // Here we have number of rows(200) limitation for UserRecordAccess
        // so need to iterate those all records and prepare that map
        List<List<Object>> listAllRecordIdsInChunks = prepareSubLists(recordIds, 200);

        // Iterate over sublist(200 records) of reocrd ids and assign those
        // record details to map
        for (List<Object> listRecordIds : listAllRecordIdsInChunks){

            List<String> list200RecordIds = new List<String>();
            for (Object objRecordId : listRecordIds){
                list200RecordIds.Add(String.ValueOf(objRecordId));
            }

            for (UserRecordAccess UserRecord : [SELECT RecordId, HasEditAccess
                                                FROM UserRecordAccess
                                                WHERE UserId = :UserInfo.getUserId() AND RecordId IN :list200RecordIds
                                                LIMIT 200]){
                mapRecordIdToAccess.put(UserRecord.RecordId, UserRecord.HasEditAccess);
            }
        }
        return mapRecordIdToAccess;
    }

    /**
     Given a list of objects and a sublist size, return a list of sublists.
     **/
    public static List<List<Object>> prepareSubLists(List<Object> objectsList, Integer subListSize){

        List<List<Object>> objectsSubLists = new List<List<String>>();
        if (objectsList.isEmpty() || objectsList.size() <= subListSize){
            objectsSubLists.add(objectsList);
            return objectsSubLists;
        }

        Integer objectsCount = objectsList.size();
        Integer subListsCount = (objectsList.size() / subListSize)+1;

        // iterate over the possible number of sublists
        for (Integer i = 0; i < subListsCount; i++){
            List<Object> subList = new List<String>();
            for (Integer j = 0; j < subListSize; j++){
                Integer nextObjectIndex = i * subListSize + j;
                // The last sublist might not be full, handle that case
                if (nextObjectIndex < objectsCount){
                    subList.add(objectsList.get(nextObjectIndex));
                }
            }
            objectsSubLists.add(subList);
        }
        return objectsSubLists;
    }

    // check if the current logged in user has "Modify All Data" permission
    public static Boolean hasModifyAllDataPermission(){
        try{
            Id currentUserId = UserInfo.getUserId();
            User currentUser;
            if (Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.Profile.fields.PermissionsModifyAllData.isAccessible()){
                currentUser = [SELECT Profile.PermissionsModifyAllData
                               FROM User
                               WHERE Id = :currentUserId];
            }
            return currentUser.Profile.PermissionsModifyAllData;
        } catch (Exception ex){
            // ignore
        }
        return false;
    }

    // check if the current user has "ModifyAllRecords" permission on specific object type
    public static Boolean hasModifyAllPermissionForObjectType(String objectType){
        List<PermissionSetAssignment> permissionSetAssignmentList;

        permissionSetAssignmentList = [Select PermissionSetId, Id, AssigneeId
                                       From PermissionSetAssignment
                                       WHERE PermissionSetId IN (SELECT ParentId
                                                                 FROM ObjectPermissions
                                                                 WHERE SobjectType = :objectType AND PermissionsModifyAllRecords = true) and Assignee.IsActive = true and Assignee.Id = :UserInfo.getUserId()];

        //if there is a permission set assignment record, then the user has the permission
        if (permissionSetAssignmentList != null && permissionSetAssignmentList.size() > 0){
            return true;
        } else{
            return false;
        }
    }

    /**********************************************************************************************************
     Purpose: This method will be used to retrieve the list of sobjects using query string and with/without sharing flag.
     Parameters:  isForWithoutSharing - True if you want to by pass the security sharing for object you are querying.
     queryString - Query string to retirive objects.
     Returns:     List of sobjects
     Throws [Exceptions]:
     **********************************************************************************************************/
    public static list<Sobject> queryForWithOrWithoutSharing(Boolean isForWithoutSharing, String queryString){
        if (isForWithoutSharing){
            return BT_NoSharingUtils.getObjectsUsingQueryString(queryString);
        } else{
            return Database.query(queryString);
        }
        // return null;
    }

    /**********************************************************************************************************
     Purpose: This method will be used to retrieve the Record count using query string and with/without sharing flag.
     Parameters:  isForWithoutSharing - True if you want to by pass the security sharing for object you are querying.
     queryString - Query string to retirive objects.
     Returns:     Integer (Record Count)
     Throws [Exceptions]:
     **********************************************************************************************************/
    public static Integer getRecordCountWithOrWithoutSharing(Boolean isForWithoutSharing, String queryString){
        if (isForWithoutSharing){
            return BT_NoSharingUtils.getRecordCountUsingQueryString(queryString);
        } else{
            return Database.countQuery(queryString);
        }
       // return null;
    }

    /**********************************************************************************************************
     Purpose: This method will be used to insert the list of sobjects in with/without sharing manner.
     Parameters:  isForWithoutSharing - True if you want to by pass the security sharing for object you are inserting.
     recordsToInsert - List of sobject you want to insert.
     Returns:
     Throws [Exceptions]:
     **********************************************************************************************************/
    public static void doInsertWithOrWithoutSharing(Boolean isForWithoutSharing, List<sObject> recordsToInsert){
        if (isForWithoutSharing){
            BT_NoSharingUtils.doInsert(recordsToInsert, true);
        } else{
            DMLManager.insertAsUser(recordsToInsert);
        }
    }

    /**********************************************************************************************************
     Purpose: This method will be used to update the list of sobjects in with/without sharing manner.
     Parameters:  isForWithoutSharing - True if you want to by pass the security sharing for object you are updating.
     recordsToUpdate - List of sobject you want to update.
     Returns:
     Throws [Exceptions]:
     **********************************************************************************************************/
    public static void doUpdateWithOrWithoutSharing(Boolean isForWithoutSharing, List<sObject> recordsToUpdate){
        if (isForWithoutSharing){
            BT_NoSharingUtils.doUpdate(recordsToUpdate, true);
        } else{
            DMLManager.updateAsUser(recordsToUpdate);
        }
    }

    /**********************************************************************************************************
     Purpose: This method will be used to upsert the list of sobjects in with/without sharing manner.
     Parameters:  isForWithoutSharing - True if you want to by pass the security sharing for object you are upserting.
     recordsToUpsert - List of sobject you want to upsert.
     Returns:
     Throws [Exceptions]:
     **********************************************************************************************************/
    public static void doUpsertWithOrWithoutSharing(Boolean isForWithoutSharing, List<sObject> recordsToUpsert){
        if (isForWithoutSharing){
            BT_NoSharingUtils.doUpsert(recordsToUpsert);
        } else{
            upsert recordsToUpsert;
        }
    }

    /**********************************************************************************************************
     Purpose: This method will be used to delete the list of sobjects in with/without sharing manner.
     Parameters:  isForWithoutSharing - True if you want to by pass the security sharing for object you are deleting.
     recordsToInsert - List of sobject you want to delete.
     Returns:
     Throws [Exceptions]:
     **********************************************************************************************************/
    public static void doDeleteWithOrWithoutSharing(Boolean isForWithoutSharing, List<sObject> recordsToDelete){
        if (isForWithoutSharing){
            BT_NoSharingUtils.doDelete(recordsToDelete, true);
        } else{
            DMLManager.deleteAsUser(recordsToDelete);
        }
    }

    /**********************************************************************************************************
     Purpose: This method will be used to prepare the query string from set of ids you want to check for "IN" clause.
     Parameters:  setIdValues - Set of Ids you are going to use in "IN" clause.
     Returns:     Query string for IN clause i.e  ('a0A121212114rw4', 'a0A454rere24wedq5')
     Throws [Exceptions]:
     **********************************************************************************************************/
    public static string prepareQueryStringForInClause(Set<Id> setIdValues){
        Set<String> setStringValue = new Set<String>();
        for (Id value : setIdValues){
            if (value != null){
                setStringValue.add(value);
            }
        }
        return prepareQueryStringForInClause(setStringValue);
    }

    /**********************************************************************************************************
     Purpose: This method will be used to prepare the query string from set of ids you want to check for "IN" clause.
     Parameters:  setStringValues - List of String you are going to use in "IN" clause.
     Returns:     Query string for IN clause i.e  ('In Progress', 'Completed')
     Throws [Exceptions]:
     **********************************************************************************************************/
    public static string prepareQueryStringForInClause(Set<String> setStringValues){
        if (setStringValues.isEmpty()){
            return '(null)';
        }
        String valuesInClause = '( ';
        for (String value : setStringValues){
            valuesInClause += '\'' + value + '\',';
        }
        valuesInClause = valuesInClause.substring(0, valuesInClause.length()-1);
        valuesInClause += ')';
        return valuesInClause;
    }

    /**********************************************************************************************************
     Purpose: This method will be used to prepare the query string "=" clause. If the value is null then ='null' will not work
     in that case it should be like = null
     Parameters:  value - Value you are going to use with "=".
     Returns:     Query string for "=" clause i.e  'In Progress' or null
     Throws [Exceptions]:
     **********************************************************************************************************/
    public static string prepareQueryStringForEqualClause(String value){
        if (value != null){
            return '\'' + value + '\'';
        } else{
            return 'null';
        }
    }

    /* get the namespace prefix of the package that this cod eis part of.
     For development orgs, this will retun an empty string. */
    public static String getNamespacePrefix(){
        String namespacePrefix = '';
        if (BT_CONSTANTS.OBJECT_TYPE_PROJECT != 'Project__c'){
            namespacePrefix = BT_CONSTANTS.OBJECT_TYPE_PROJECT.substring(0, BT_CONSTANTS.OBJECT_TYPE_PROJECT.indexOf('Project__c'));
        }
        return namespacePrefix;
    }

    /**
     given an object type name, returns true if it has a record type
     **/
    public static Boolean hasRecordType(String objectTypeName){
        System.debug('getObjectTypeFromTypeName(objectTypeName)::' + getObjectTypeFromTypeName(objectTypeName));
        Schema.Sobjecttype st = getObjectTypeFromTypeName(objectTypeName);

        if (st != null){
            Schema.DescribeSObjectResult dr = st.getDescribe();
            if (dr != null){
                System.debug('Dr::' + dr);
                Map<String, RecordTypeInfo> recordTypeInfosByName = dr.getRecordTypeInfosByName();

                // see if there are record type infos other than the master
                if (recordTypeInfosByName.size() > 1){
                    return true;
                }
            }
        }
        return false;
    }

    /**
     Converts nvPairsString into Map
     The nvPairsString can be of the form Name#Vaue~N2#V2... where ^ is nvSeparator and ~ is pairSeparator
     @param nvPairsString (name, value) pairs in specified format
     @param nvSeparator - name, value separator charactor
     @param pairSeparator - pairs separator charactor
     **/
    public static Map<String, String> convertNVStringToMap(String nvPairsString, String nvSeparator, String pairSeparator){
        // queryNVPairs is in the form of Name#Vaue~N2#V2... prepare queryString map of (n,v)
        Map<String, String> pairMap = new Map<String, String>();
        if (nvPairsString != null && nvPairsString != ''){
            List<String> nvPairs = nvPairsString.split(pairSeparator);
            for (String nvP : nvPairs){
                if (nvP != ''){
                    List<String> nv = nvP.split(nvSeparator);
                    if (nv.size() > 1){
                        pairMap.put(nv.get(0), nv.get(1));
                    }
                }
            }
        }
        return pairMap;
    }

    /*
     *   Executed:   From any class.
     *   Purpose:    Funxtion will return the Object type using object name
     *   Parameters: object name
     *   UnitTests:
     */
    public static Schema.Sobjecttype getObjectTypeFromTypeName(String typeName){
        return getObjectTypeFromTypeName(typeName, false);
    }

    /*
     *   Executed:   From any class.
     *   Purpose:    Funxtion will return the Object type using object name
     *   Parameters: object name
     *   UnitTests:
     */
    public static Schema.Sobjecttype getObjectTypeFromTypeName(String typeName, Boolean nullOk){
        String updatedTypeName = BT_Constants.OBJECT_NAMESPACE_MAP.get(typeName);
        if (updatedTypeName == null){
            updatedTypeName = typeName;
        }
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.Sobjecttype st = gd.get(updatedTypeName);
        return st;
    }

    //Return SobjectField usign object and field name.
    public static Schema.SObjectField getField(String objectName, String fieldName){
        Schema.Sobjecttype sot = getObjectTypeFromTypeName(objectName);

        if (sot != null){
            Schema.DescribeSObjectResult dr = sot.getDescribe();
            Map<String, Schema.SObjectField> fields = dr.fields.getMap();
            return fields.get(fieldName);
        }
        return null;
    }

    /*The method returns all the fields from the specified fieldset. If the fieldset is passed without the
     namespace, first the method checks if the same name fieldset is available outside package, the it returns
     fields in that fieldset otherwise it will check packaged fieldset. However, if someone directly passes a
     fieldset with the namespace, then it will check the packaged fieldset only. */
    public static List<Schema.FieldSetMember> getFieldSetMembers(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        String namespacePrefix = BT_UTILS.getNamespacePrefix();

        if (SObjectTypeObj != null){
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

            if (fieldSetObj != null){
                system.debug('fieldSetObj.getFields() *********' + fieldSetObj.getFields());
                return fieldSetObj.getFields();
            } else if (!fieldSetName.startsWith(namespacePrefix)){
                return getFieldSetMembers(namespacePrefix + fieldSetName, ObjectName);
            }
        }
        return new List<Schema.FieldSetMember>();
    }

    /**************************************************************************
     Purpose: Prepare the select option for field.
     Parameters:
     Returns:
     Throws [Exceptions]:
     ****************************************************************************/
    public static List<SelectOption> getPickListValues(String objectName, String fieldName){
        Schema.SObjectField field = getField(objectName, fieldName);
        List<Schema.PicklistEntry> pickListValues = field.getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for (Schema.PicklistEntry a : pickListValues){
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }

    /**************************************************************************
     Purpose: Given a list of fieldset members and a list of additional field names,
     build a SOQL select list fragment making sure that it does not contain
     duplicate field names.
     Parameters: fieldSetMembers - List of fieldset members
     secondaryFieldSetMembers - List of fieldset members for header fields
     additionalFields - List of string with comma separated field api names
     Returns: List of FieldSetMember
     Throws [Exceptions]:
     ****************************************************************************/
    public static String buildSelectListFragment(List<Schema.FieldSetMember> fieldSetMembers, List<Schema.FieldSetMember> secondaryFieldSetMembers, List<String> additionalFields){
        String nameSpacePrefix = BT_Utils.getNamespacePrefix();

        Set<String> selectFields = new Set<String>();
        String selectString = '';

        // first add the fields from the field set
        if (fieldSetMembers != null && fieldSetMembers.size() > 0){
            for (Schema.FieldSetMember objFieldSetMember : fieldSetMembers){
                selectFields.add(objFieldSetMember.getFieldPath().toLowerCase());

                if (selectString.length() > 0){
                    selectString += ', ';
                }
                selectString += objFieldSetMember.getFieldPath();
            }
        }

        if (secondaryFieldSetMembers != null){
            // add the fields from the secondary field set
            for (Schema.FieldSetMember objFieldSetMember : secondaryFieldSetMembers){
                String fieldPath = objFieldSetMember.getFieldPath();
                if (!selectFields.contains(fieldPath.toLowerCase())){
                    selectFields.add(fieldPath.toLowerCase());
                    if (selectString.length() > 0){
                        selectString += ', ';
                    }
                    selectString += fieldPath;
                }
            }
        }

        // now add the additional fields only if the fields have not already been added
        for (String additionalField : additionalFields){
            if (!selectFields.contains(additionalField.toLowerCase()) && (!selectFields.contains((nameSpacePrefix + additionalField).toLowerCase()))){
                selectFields.add(additionalField.toLowerCase());
                if (selectString.length() > 0){
                    selectString += ', ';
                }
                selectString += additionalField;
            }
        }
        system.debug('selectString---->' + selectString);
        return selectString;
    }

    /*
     *   Executed:   From any class.
     *   Purpose:    Function will return comma seperated list of field api for object. we can use this string into query string
     *   Parameters: object name
     *   UnitTests:
     */
    public static string getQueryStringForObjectWithAllFields(String objectType){
        String queryString;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.Sobjecttype sot = BT_Utils.getObjectTypeFromTypeName(objectType);
        if (sot != null){
            Schema.DescribeSObjectResult dr = sot.getDescribe();
            // all fields of attestation object
            Map<String, Schema.SObjectField> fields = dr.fields.getMap();
            integer i = 0;
            queryString = ' ';
            for (String field : fields.keyset()){
                if (i == 0){
                    queryString += field;
                } else{
                    queryString += ', ' + field;
                }
                i++;
            }
        }
        system.debug('queryString ----------> ' + queryString);
        return queryString;
    }

    /*
     *   Purpose:    When select options will be moved to right this method will be used
     *   Parameters: leftAvailableOptions     = All available options on left select list
     *                lefttSelectedValues        = Selected values on left list
     *                rightAvailableOptions    = All available options on right select list. This will be updated
     *   UnitTests:
     */
    public static List<SelectOption> movingSelectOptionsToRight(List<SelectOption> leftAvailableOptions, List<String> leftSelectedValues, List<SelectOption> rightAvailableOptions){
        Set<String> selectedInspectorsFromAvailableSet = new Set<String>();
        selectedInspectorsFromAvailableSet.addAll(leftSelectedValues);
        List<SelectOption> updatedAvailableInspectors = new List<SelectOption>();
        for (SelectOption availableItem : leftAvailableOptions){
            if (selectedInspectorsFromAvailableSet.contains(availableItem.getValue())){
                rightAvailableOptions.add(availableItem);
            } else{
                updatedAvailableInspectors.add(availableItem);
            }
        }
        leftAvailableOptions = updatedAvailableInspectors;
        return leftAvailableOptions;
    }

    /*
     *   Purpose:    When select options will be moved to left this method will be used
     *   Parameters: rightAvailableOptions     = All available options on right select list
     *                rightSelectedValues        = Selected values on right list
     *                leftAvailableOptions    = All available options on left select list. This will be updated
     *   UnitTests:
     */
    public static List<SelectOption> movingSelectOptionsToLeft(List<SelectOption> rightAvailableOptions, List<String> rightSelectedValues, List<SelectOption> leftAvailableOptions){
        Set<String> selectedInspectorsFromSelectedSet = new Set<String>();
        selectedInspectorsFromSelectedSet.addAll(rightSelectedValues);
        List<SelectOption> updatedSelectedInspectors = new List<SelectOption>();
        for (SelectOption selectedItem : rightAvailableOptions){
            if (selectedInspectorsFromSelectedSet.contains(selectedItem.getValue())){
                leftAvailableOptions.add(selectedItem);
            } else{
                updatedSelectedInspectors.add(selectedItem);
            }
        }
        rightAvailableOptions = updatedSelectedInspectors;
        return rightAvailableOptions;
    }

    /*
     *   Purpose:    Given a string and a separator, tokenize the string, trim the spaces from the tokens and retun a list of
     tokens. Make sure to eliminae empty tokens.
     *   Parameters: stringWithSeparator
     separator
     *   UnitTests:
     */
    public static list<String> tokenizeStringWithSeparator(String stringWithSeparator, String separator){
        List<String> tokens = new List<String>();
        if (stringWithSeparator == null){
            return tokens;
        }

        String regex;
        // regex to split on comma and ignore comma between quoted strings.
        // split on the comma only if that comma has zero, or an even number of quotes ahead of it.
        if (separator == ','){
            regex = ',(?=([^\"]*\"[^\"]*\")*[^\"]*$)';
        } else if (separator == ';'){
            regex = ';(?=([^\"]*\"[^\"]*\")*[^\"]*$)';
        } else{
            regex = separator;
        }

        for (String token : stringWithSeparator.split(regex)){
            if (token.trim() != ''){
                tokens.add(token.trim());
            }
        }
        return tokens;
    }

    /**************************************************************************
     Purpose: Get comma separated string of all field API names of any object
     based on field type passed as parameter "strFieldType".
     Parameters: strObjectName - Object API Name
     strFieldType - Type of field
     blnIsHtmlFormatted - Html Formatted(If field type is richtext(TextArea), need to pass true)
     Returns: strFieldAPINames - Comma separated API names of "strFieldType" fields
     Throws [Exceptions]:
     ****************************************************************************/
    public static String getFieldAPINamesUsingType(String strObjectName, String strFieldType, Boolean blnIsHtmlFormatted){
        if (strObjectName != null && strObjectName.trim() != '' && strFieldType != null && strFieldType.trim() != '' &&
                        Schema.getGlobalDescribe().get(strObjectName) != null){

            String strFieldAPINames = '';
            Map<String, Schema.SObjectField> mapSchemaFields = Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap();
            for (Schema.SObjectField objSchemaField : mapSchemaFields.Values()){
                Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
                if (objFieldDescribe.getType() != null && String.ValueOf(objFieldDescribe.getType()).toUpperCase() == strFieldType.trim().toUpperCase() && objFieldDescribe.isHtmlFormatted() == blnIsHtmlFormatted){
                    strFieldAPINames += objFieldDescribe.getName()+',';
                }
            }
            return strFieldAPINames;
        }
        return null;
    }

    /**************************************************************************
     Purpose: Get static resource URL
     Throws [Exceptions]:
     ****************************************************************************/
    public static String getResourceURL(String resourceName){
        List<StaticResource> resources;
        if (Schema.sObjectType.StaticResource.isAccessible() && Schema.sObjectType.StaticResource.fields.Name.isAccessible() && Schema.sObjectType.StaticResource.fields.NamespacePrefix.isAccessible() && Schema.sObjectType.StaticResource.fields.SystemModStamp.isAccessible()){
            resources = [SELECT Name, NamespacePrefix, SystemModStamp
                         FROM StaticResource
                         WHERE Name = :resourceName];
        }
        if (!resources.isEmpty()){
            string namespace = resources[0].NamespacePrefix;
            return '/resource/' + resources[0].SystemModStamp.getTime()+'/' + (namespace != null && namespace != '' ? namespace + '__' : '')+resourceName;
        } else{
            return '';
        }
    }

    // Method used to convert date in to string.
    public static String getDateAsString(Date dateValue){
        Integer day = dateValue.day();
        Integer month = dateValue.month();
        Integer year = dateValue.year();
        String dateValueInSTring = String.valueOf(day)+'-';
        dateValueInSTring += getMonthAsString(month);
        dateValueInSTring += '-' + String.valueOf(year);
        return dateValueInSTring;
    }

    // Get sobject prefix, if not found, returns null
    public static String getSObjectPrefix(String objectType){
        String prefix = null;
        Schema.Sobjecttype st = getObjectTypeFromTypeName(objectType);

        if (st != null){
            Schema.DescribeSObjectResult dr = st.getDescribe();
            if (dr != null){
                prefix = dr.getKeyPrefix();
            }
        }
        return prefix;
    }

    public static string getSobjectTypeFromKeyPrefix(String keyPrefix){
        String sobjectType;
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
        for (Schema.SObjectType sobjType : gd){
            if (sobjType != null){
                Schema.DescribeSObjectResult dr = sobjType.getDescribe();
                if (dr != null && dr.getKeyPrefix() == keyPrefix){
                    sobjectType = String.valueOf(sobjType);
                    return sobjectType;
                }
            }
        }
        return null;
    }

    /**
     given an object type name and a record type name, get the record type Id
     **/
    public static Id getRecordTypeId(String objectTypeName, String recordTypeName){
        Schema.Sobjecttype st = getObjectTypeFromTypeName(objectTypeName);

        if (st != null){
            Schema.DescribeSObjectResult dr = st.getDescribe();
            if (dr != null){
                Map<String, RecordTypeInfo> recordTypeInfosByName = dr.getRecordTypeInfosByName();
                if (recordTypeInfosByName != null){
                    RecordTypeInfo rtInfo = recordTypeInfosByName.get(recordTypeName);
                    if (rtInfo != null){
                        return rtInfo.getRecordTypeId();
                    }
                }
            }
        }
        return null;
    }

    // Method used to convert date in to string.
    public static String getMonthAsString(Integer month){
        String monthValue = '';
        if (month == 1){
            monthValue = 'Jan';
        } else if (month == 2){
            monthValue = 'Feb';
        } else if (month == 3){
            monthValue = 'Mar';
        } else if (month == 4){
            monthValue = 'Apr';
        } else if (month == 5){
            monthValue = 'May';
        } else if (month == 6){
            monthValue = 'Jun';
        } else if (month == 7){
            monthValue = 'Jul';
        } else if (month == 8){
            monthValue = 'Aug';
        } else if (month == 9){
            monthValue = 'Sep';
        } else if (month == 10){
            monthValue = 'Oct';
        } else if (month == 11){
            monthValue = 'Nov';
        } else if (month == 12){
            monthValue = 'Dec';
        }
        return monthValue;
    }

    /*
     File object that is used to pass file detail from page to controller.
     */
    public class File{
        Public Integer Size{ get; set; }

        Public String Name{ get; set; }

        Public String Extension{ get; set; }

        Public String ContentType{ get; set; }

        Public String BucketName;
        Public String Folder;
        Public Boolean Replace;
        public File(){
        }
    }

    public static String fillStringWithSlods(List<BT_FilterCondition.Filter> filterList, String filterLogic){
        String condition = '';
        Integer strLength = filterLogic.length();
        String numericString = '';
        String tempNumber = '';
        String templateOperator = '';

        for (integer i = 0; i < filterLogic.length(); i++){
            String s = filterLogic.mid(i, 1);
            if (s.isNumeric()){
                numericString += s;
                tempNumber = numericString;
                if (templateOperator != ''){
                    condition += templateOperator;
                    templateOperator = '';
                }

            } else{
                templateOperator += s;
                numericString = '';
            }

            if (numericString == '' && tempNumber != ''){
                Integer indexNum = Integer.valueOf(tempNumber);
                indexNum--;
                BT_FilterCondition.Filter filter = null;
                try{
                    filter = filterList.get(indexNum);
                } catch (Exception ex){
                    throw new GlobalUtilityException('Filter logic provided is incorrect!!!');
                }
                condition += ' ';
                condition += filter.getFilterUnit();
                tempNumber = '';
                if (i == filterLogic.length()-1){
                    condition += s;
                }
            }
        }
        if (tempNumber != ''){
            if (templateOperator != ''){
                condition += templateOperator;
            }
            Integer indexNum = Integer.valueOf(tempNumber);
            indexNum--;
            BT_FilterCondition.Filter filter = null;
            try{
                filter = filterList.get(indexNum);
            } catch (Exception ex){
                throw new GlobalUtilityException('Filter logic provided is incorrect!!!');
            }
            condition += ' ';
            condition += filter.getFilterUnit();
            tempNumber = '';
        }
        return condition;
    }

    public static Map<String, Object> handleWithDMLException(DMLException ex){
        Integer errorNumber = ex.getNumDml();
        List<Map<String, String>> errorResults = new List<Map<String, String>>();
        Map<String, Object> errors = new Map<String, Object>();
        for (Integer i = 0; i < errorNumber; i++){
            Map<String, String> errorMap = new Map<String, String>();
            errorMap.put('index', '' + ex.getDmlIndex(i));
            errorMap.put('fields', '' + ex.getDmlFields(i));
            errorMap.put('message', '' + ex.getDmlMessage(i));
            errorResults.add(errorMap);
        }
        errors.put('errorResults', errorResults);
        errors.put('message', ex.getMessage());
        errors.put('statusCode', ex.getTypeName());
        errors.put('IsSuccess', false);

        return errors;
    }

    public static String strErrorMsg;
    public static List<String> cond;
    Public static List<Sobject> CloneAny(String objName, String recId, String parentFieldApiName, String childObjName){
        return CloneAny(objName, recId, parentFieldApiName, childObjName, '');
    }

    Public static List<Sobject> CloneAny(String objName, String recId, String parentFieldApiName, String childObjName, String projectId){
        System.debug('objName :: ' + objName);
        Map<String, String> additionalFields = new Map<String, String>();
        if (projectId != null && projectId != '')
            additionalFields.put('Project__c', projectId);
        return CloneAny(objName, recId, parentFieldApiName, childObjName, additionalFields);
    }

    //Pass the parameters as 1. Parent Object API Name, 2. Source record id, 3. API Name of the related field, 4. Child Object API Name
    Public static List<Sobject> CloneAny(String objName, String recId, String parentFieldApiName, String childObjName, Map<String, String> additionalFields){
        System.debug('##CloneAny :: ' + objName);
        string qryStr = prepareQuery(objName, 'Id', recId);
        System.debug('##qryStr' + qryStr);
        List<Sobject> sobjListToClone = database.query(qryStr);
        System.debug('##sobjListToClone :' + sobjListToClone);
        Map<Id, Sobject> cloneSObjList = new Map<Id, Sobject>();
        for (Sobject sobj : sobjListToClone){
            if (additionalFields != null && additionalFields.size() > 0){
                for (String keyAPI : additionalFields.keyset()){
                    sobj.put(keyAPI, additionalFields.get(keyAPI));
                }
            }
            cloneSObjList.put(sobj.Id, sobj.clone(false, true));
        }
        System.debug('##cloneSObjList :' + cloneSObjList.values());

        if (objName == 'buildertek__Purchase_Order__c'){
            for (Sobject po : cloneSObjList.values()){
                po.put('buildertek__Status__c', 'Pending');
            }
        }
        //insert cloneSObjList;
        Database.SaveResult[] result = Database.Insert(cloneSObjList.values(), false);

        System.debug('##cloneSObjList Failed:' + result);
        Integer count = 0;
        // Iterate through each returned result
        for (Database.SaveResult sr : result){
            if (sr.isSuccess()){
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted: ' + sr.getId());
            } else{

                // Operation failed, so get all errors

                for (Database.Error err : sr.getErrors()){
                    count++;
                    System.debug('The following error has occurred.');
                    strErrorMsg = ': ' + err.getMessage();
                    System.debug(err.getStatusCode()+': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }

            }

        }
        if (!String.isEmpty(strErrorMsg))
            strErrorMsg = count + ' record cannot be cloned due to ' + strErrorMsg;
        if (childObjName != null && parentFieldApiName != null){
            string childQry = prepareQuery(childObjName, parentFieldApiName, recId);
            List<Sobject> sobjList = database.query(childQry);
            List<Sobject> clonedSobjList = new List<Sobject>();

            Map<Id, Sobject> cloneSObjGroupList = new Map<Id, Sobject>();


            if (childObjName == 'buildertek__Quote_Item__c'){
                string childGroupQry = prepareQuery('buildertek__Quote_Line_Group__c', parentFieldApiName, recId);
                List<Sobject> sobjGroupList = database.query(childGroupQry);
                system.debug('sobjGroupList ---------> ' + sobjGroupList);
                system.debug('sobjGroupList size ---------> ' + sobjGroupList.size());
                List<Sobject> clonedSobjGroupList = new List<Sobject>();

                system.debug('tFieldApiName ---------> ' + parentFieldApiName);
                for (Sobject sobj : sobjGroupList){
                    system.debug('Key set -----------> ' + cloneSObjList.keyset());
                    for (Id parentId : cloneSObjList.keyset()){
                        system.debug('parentFieldApiName ---------> ' + sobj.get(parentFieldApiName));
                        system.debug('parentId ---------> ' + parentId);
                        //if(sobj.get(parentFieldApiName) == parentId){
                        Sobject obj = sobj.clone(false, true);
                        //obj.put(parentFieldApiName, cloneSObjList.get(parentId).id);//Changing the parent id

                        cloneSObjGroupList.put(sobj.Id, obj);
                        //}
                    }
                }

                /*if(cloneSObjGroupList.values() != null)
                 system.debug('cloneSObjGroupList --------> '+cloneSObjGroupList.values());
                 insert cloneSObjGroupList.values();*/
            }

            if (childObjName == 'buildertek__Contract_Item__c'){
                string childGroupQry = prepareQuery('buildertek__Quote_Line_Group__c', parentFieldApiName, recId);
                List<Sobject> sobjGroupList = database.query(childGroupQry);
                List<Sobject> clonedSobjGroupList = new List<Sobject>();


                for (Sobject sobj : sobjGroupList){
                    for (Id parentId : cloneSObjList.keyset()){
                        //if(sobj.get(parentFieldApiName) == parentId){
                        Sobject obj = sobj.clone(false, true);
                        //obj.put(parentFieldApiName, cloneSObjList.get(parentId).id);//Changing the parent id

                        cloneSObjGroupList.put(sobj.Id, obj);
                        //}
                    }
                }

                /*if(cloneSObjGroupList.values() != null)
                 insert cloneSObjGroupList.values();*/
            }

            if (childObjName == 'buildertek__Budget_Item__c'){
                string childGroupQry = prepareQuery('buildertek__Budget_Item__c', parentFieldApiName, recId);
                List<Sobject> sobjGroupList = database.query(childGroupQry);
                List<Sobject> clonedSobjGroupList = new List<Sobject>();


                for (Sobject sobj : sobjGroupList){
                    for (Id parentId : cloneSObjList.keyset()){
                        //if(sobj.get(parentFieldApiName) == parentId){
                        Sobject obj = sobj.clone(false, true);
                        //obj.put(parentFieldApiName, cloneSObjList.get(parentId).id);//Changing the parent id

                        cloneSObjGroupList.put(sobj.Id, obj);
                        //}
                    }
                }

                /*if(cloneSObjGroupList.values() != null)
                 insert cloneSObjGroupList.values();*/
            }
            Map<String,SObject> projectTaskMap = new Map<String,SObject>();

            List<sObject> cloneChildRec= new List<sObject>();


            for (Sobject sobj : sobjList){

                System.debug('sobj ==> '+sobj);

                if (sobj.get(parentFieldApiName) != null){
                    for (Id parentId : cloneSObjList.keyset()){
                        if (sobj.get(parentFieldApiName) == parentId){

                            Sobject obj = sobj.clone(false, true);
                            obj.put(parentFieldApiName, cloneSObjList.get(parentId).id);//Changing the parent id
                            system.debug('---obj---' + obj);


                            if (childObjName == 'buildertek__Contract_Item__c' && sobj.get('buildertek__Contract_Line_Group__c') != null){
                                system.debug('Contract Group Id ---------> ' + sobj.get('buildertek__Grouping__c'));
                                system.debug('Contract sObjeGroupList --------> ' + cloneSObjGroupList);
                                system.debug('Contract Grouping --------> ' + cloneSObjGroupList.get((Id)sobj.get('buildertek__Grouping__c')));
                                // obj.put('buildertek__Contract_Line_Group__c', cloneSObjGroupList.get((Id)sobj.get('buildertek__Contract_Line_Group__c')).id);//Changing the Group id
                                obj.put('buildertek__Contract_Line_Group__c', sobj.get('buildertek__Contract_Line_Group__c'));//Changing the Group id

                            }

                            if (childObjName == 'buildertek__Quote_Item__c' && sobj.get('buildertek__Grouping__c') != null){

                                system.debug('Quote Group Id ---------> ' + sobj.get('buildertek__Grouping__c'));
                                system.debug('sObjeGroupList --------> ' + cloneSObjGroupList);
                                system.debug('Grouping --------> ' + cloneSObjGroupList.get((Id)sobj.get('buildertek__Grouping__c')));
                                // obj.put('buildertek__Grouping__c', cloneSObjGroupList.get((Id)sobj.get('buildertek__Grouping__c')).id);//Changing the Group id
                                obj.put('buildertek__Grouping__c', sobj.get('buildertek__Grouping__c'));//Changing the Group id

                            }

                            if (childObjName == 'buildertek__Budget_Item__c' && sobj.get('buildertek__Group__c') != null && cloneSObjGroupList.get((Id)sobj.get('buildertek__Group__c')) != null){
                                // obj.put('buildertek__Group__c', cloneSObjGroupList.get((Id)sobj.get('buildertek__Group__c')).id);//Changing the Group id
                                obj.put('buildertek__Group__c', sobj.get('buildertek__Group__c'));//Changing the Group id

                            }

                            // here we are getting parent as null for some resone we need to investigate this in detail
                            // for now just put the parent not null check
                            if (obj.get(parentFieldApiName) != null){
                                clonedSobjList.add(obj);
                                if(childObjName == 'buildertek__Project_Task__c'){
                                    projectTaskMap.put(String.valueOf(sobj.get('Id')),obj);
                                }
                            }

                            cloneChildRec.add(obj);


                        }
                    }
                }
            }

            if(cloneChildRec.size() > 0){
                insert cloneChildRec;
            }
            // Add Code For Change Predecessor (Start)

            if (childObjName == 'buildertek__Project_Task__c') {
                Map<String, String> predecessorMap = new Map<String, String>();

                if (projectTaskMap.size() > 0) {
                    for (String key : projectTaskMap.keySet()) {
                        buildertek__Project_Task__c task= (buildertek__Project_Task__c)projectTaskMap.get(key);
                        System.debug('Sobject ==> '+task);
                        if (task.buildertek__Dependency__r != null) {
                            if (!predecessorMap.containsKey(key)){
                                predecessorMap.put(key, task.buildertek__Dependency__c);
                            }
                            task.buildertek__Dependency__c = null;
                            // task.buildertek__Start__c = System.today();
                        }
                        projectTaskMap.put(key, task);
                    }
                    // insert projectTaskMap.values();
                    Database.SaveResult[] saveResultList = Database.insert (projectTaskMap.values(), false);
                }

                List<buildertek__Project_Task__c> updateTask = new List<buildertek__Project_Task__c>();
                for (String key : predecessorMap.keySet()) {
                    System.debug('Task Id ==> '+key +' : Predecessor Id ==> '+predecessorMap.get(key));

                    buildertek__Project_Task__c task= (buildertek__Project_Task__c)projectTaskMap.get(key);
                    task.buildertek__Dependency__c = (projectTaskMap.get(predecessorMap.get(key))).Id;

                    System.debug('Task ==> '+task);
                    updateTask.add(task);
                }

                if (updateTask.size() > 0) {
                    // update updateTask;
                    ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
                    Database.SaveResult[] saveResultListt = Database.update (updateTask, false);
                    ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
                }

            }

            // Add Code For Change Predecessor (End)


            // Comment Code For Because Predecessor Logic Is Write Above

            // if(childObjName == 'buildertek__Project_Task__c'){
            //  System.debug('Child Object Project Task');
            //  insert projectTaskMap.values();
            //  List<Sobject> clonedSobjList1 = new List<Sobject>();
            //  for (Sobject sobj : sobjList){
            //      System.debug('Child Object Project Task 1'+sobj);
            //      if(projectTaskMap.get(String.valueOf(sobj.get('buildertek__Dependency__c'))) != null){
            //          sobj.put('Id',projectTaskMap.get(String.valueOf(sobj.get('Id'))).get('Id'));
            //          sobj.put('buildertek__Dependency__c',projectTaskMap.get(String.valueOf(sobj.get('buildertek__Dependency__c'))).get('Id'));
            //          clonedSobjList1.add(sobj);
            //      }
            //  }
            //  update clonedSobjList1;
            // }else{
            //  insert clonedSobjList;
            // }

        }
        return cloneSObjList.values();
    }

    //This method is used to prepare the desired query string by passing the objectname and where clause condition
    private static String prepareQuery(String sobjName, String fieldName, String recId){
        System.debug('sobjName :: ' + sobjName);
        string polinetype = 'Master';
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sobjName.toLowerCase()).getDescribe().Fields.getMap();
        String fields = '';
        for (Schema.SObjectField sf : fieldsMap.values()){
            Schema.DescribeFieldResult fr = sf.getDescribe();
            if (fr.isCreateable())
                fields += fr.getName()+',';
        }
        if (fields.endsWith(','))
            fields = fields.substring(0, fields.lastIndexOf(','));
        cond = new List<String>();
        cond = recId.split(';');
        String qryString;
        if (sobjName == 'buildertek__Quote_Line_Group__c'){
            qryString = 'Select ' + fields + ' from ' + sobjName;
        } else{
            if (sobjName == 'buildertek__Purchase_Order_Item__c'){
                qryString = 'Select ' + fields + ' from ' + sobjName + ' where buildertek__Line_Type__c = \'' + polinetype + '\'' + ' AND ' + fieldName + ' in : cond';
            } else if (sobjName == 'buildertek__Project_Task__c') {
                qryString = 'Select ' + fields + ' , buildertek__Dependency__r.Name from ' + sobjName + ' where ' + fieldName + ' in : cond';
            } else{
                qryString = 'Select ' + fields + ' from ' + sobjName + ' where ' + fieldName + ' in : cond';
            }
        }
        system.debug('qryString -------> ' + qryString);
        return qryString;
    }

    public static void genrateAutoNumber(List<sObject> recordData, List<sObject> newData, String autoNumberFieldApi){
        integer intAutoNumber = 0;
        system.debug('recordData ---------> ' + recordData);
        //         system.debug('recordData API ---------> '+recordData[0].get(autoNumberFieldApi));
        if (!recordData.IsEmpty() && recordData[0].get(autoNumberFieldApi) != null){
            intAutoNumber = integer.valueOf(recordData[0].get(autoNumberFieldApi));
        } else{
            intAutoNumber = 0;
        }

        intAutoNumber = intAutoNumber + 1;
        system.debug('intAutoNumber -------> ' + intAutoNumber);
        for (sObject obj : newData){
            string strSortId = string.valueOf(intAutoNumber);
            if (strSortId.length() == 1){
                obj.put(autoNumberFieldApi, '000' + strSortId);
            } else if (strSortId.length() == 2){
                obj.put(autoNumberFieldApi, '00' + strSortId);
            } else if (strSortId.length() == 3){
                obj.put(autoNumberFieldApi, '0' + strSortId);
            } else{
                obj.put(autoNumberFieldApi, strSortId);
            }
            intAutoNumber++;
        }
    }

    public static Boolean isValidSalesforceId(String sfdcId, System.Type t){
        try{

            if (Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(sfdcId).matches()){
                // Try to assign it to an Id before checking the type
                Id id = sfdcId;

                // Use the Type to construct an instance of this sObject
                sObject sObj = (sObject)t.newInstance();

                // Set the ID of the new object to the value to test
                sObj.Id = id;

                // If the tests passed, it's valid
                return true;
            }
        } catch (Exception e){
            // StringException, TypeException
        }

        // ID is not valid
        return false;
    }

    public class GlobalUtilityException extends Exception{
    }
}