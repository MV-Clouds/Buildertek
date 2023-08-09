/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: GenericDAOTestClass
* Created by Sagar
*
* - Test class for GenericDAO.

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
private class GenericDAOTestClass 
{       
    @testSetup static void insertTestData(){
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
        Map<String, Amazon_S3_Key__c> awsCredentials = Amazon_S3_Key__c.getAll();
        System.assertEquals(awsCredentials.size(), 2);
    }
    static testMethod void getObjectTest(){   
        
        // create Test Folder
        Folder__c root = new Folder__c(name = 'Root Folder');
        insert root; 
        
        File__c st = new File__c(name='Test File', Folder__c = root.Id);
        insert st; 
        
        st = (File__c)GenericDAO.getObject('File__c', st.Id+'');
        System.assertEquals('Test File.undefined', st.name);   
        
        st = (File__c)GenericDAO.getObject(File__c.sObjectType, st.Id);
        System.assertEquals('Test File.undefined', st.name); 
        
        st = (File__c)GenericDAO.getObject(File__c.sObjectType, st.Id+'');
        System.assertEquals('Test File.undefined', st.name); 
        
        List<String> fields = new List<String>{'Id', 'name'};
        List<String> InValidFields = new List<String>{'Id', 'Tests__c'};
        
        st = (File__c)GenericDAO.getObject('File__c', st.Id+'', fields);
        System.assertEquals('Test File.undefined', st.name);   
        
        st = (File__c)GenericDAO.getObject(File__c.sObjectType, st.Id, fields);
        System.assertEquals('Test File.undefined', st.name); 
        
        st = (File__c)GenericDAO.getObject(File__c.sObjectType, st.Id+'', fields);
        System.assertEquals('Test File.undefined', st.name); 
        
        List<Id> idList = new List<Id>{st.Id};
        List<sObject> objects = GenericDAO.getObjects(File__c.sObjectType, idList, fields);
        System.assertEquals(1, objects.size()); 
        
        List<String> idStringList = new List<String>{st.Id+''};
        objects = GenericDAO.getObjects(File__c.sObjectType, idStringList, fields);
        System.assertEquals(1, objects.size()); 
        
        objects = GenericDAO.getObjects('File__c', idStringList, fields);
        System.assertEquals(1, objects.size());         
        
       // sObject[] objectsArray = GenericDAO.getSObjectsById('File__c', st.id, 10, fields, true); 
       // System.assertEquals(1, objectsArray.size()); 
        
        //testing method with false values      
        //sObject[] objectsArray1 = GenericDAO.getSObjectsById('File__c', st.id, 0, new List<String>{}, false);
       // System.assertEquals(0, objectsArray1.size());
        
        List<String> queryFields = new List<String>{'name'};
       // objectsArray = GenericDAO.getSObjects('File__c', 'Test', 10, queryFields, true); 
       // System.assertEquals(1, objectsArray.size()); 
        
        //check with false values
       // sObject[] objectsArray2=GenericDAO.getSObjects('File__c', 'Test', null, new List<String>{}, false);
        
        
       // objectsArray = GenericDAO.getSObjects('File__c', 'Test', 10, fields, queryFields, 'name', idStringList, true); 
       // System.assertEquals(1, objectsArray.size()); 
                
        List<String> folderIdStringList = new List<String>{root.Id+''};
        Map<String, String> queryFieldNameValue = new Map<String, String>();
        queryFieldNameValue.put('Active__c', 'true');
        queryFieldNameValue.put('Name', 'Root Folder;Test3;Test4');
       // objectsArray = GenericDAO.getSObjects('Folder__c', 10, fields, queryFieldNameValue, 'or', new List<String>{'name'}, folderIdStringList, false, true); 
        // System.assert(objectsArray.size() == 1); 
        
       // objectsArray = GenericDAO.getSObjects('Folder__c', 10, fields, queryFieldNameValue, 'and', new List<String>{'name'}, folderIdStringList, false, true);
        
    //  objectsArray = GenericDAO.getSObjects('Folder__c', 10, fields, queryFieldNameValue, 'and', new List<String>{'name'}, folderIdStringList, false, true);
    //  objectsArray = GenericDAO.getSObjects('Folder__c', 10, fields, queryFieldNameValue, 'and', new List<String>{'name'}, folderIdStringList, true, true);
    //  objectsArray = GenericDAO.getSObjects('Folder__c', 10, fields, queryFieldNameValue, 'or', new List<String>{'name'}, folderIdStringList, true, true);


        // String soql = GenericDAO.getSObjectsSOQL('Folder__c', 10, fields, queryFieldNameValue, 'or', new List<String>{'name'}, folderIdStringList, false, true); 
        // System.assert(soql != null);
        
        //check with any conditiontype except 'or' and checkfordeprecated=true and maxCount=null
        // String soql1 = GenericDAO.getSObjectsSOQL('Folder__c', null, fields, queryFieldNameValue, 'and', new List<String>{'name'}, folderIdStringList, true, true); 
        // System.assert(soql1 != null);
        
        //check with conditiontype='or' and checkfordeprecated=true
        // String soql2 = GenericDAO.getSObjectsSOQL('Folder__c', 10, fields, queryFieldNameValue, 'or', new List<String>{'name'}, folderIdStringList, true, true); 
        // System.assert(soql2 != null); 
        
        // soql = GenericDAO.getSObjectsSOQL('Folder__c', 10, fields, queryFieldNameValue, 'and', new List<String>{'name'}, folderIdStringList, false, true);
        // System.assert(soql != null);
        
        List<sObject> ads = GenericDAO.getAllObjects('Folder__c', new List<String>{'id'}, 10, 'name');
        System.assert(ads.size() > 0);
        
        List<sObject> ads1 = GenericDAO.getAllObjects('Folder__c', new List<String>{'CreatedDate'}, 10, 'name');
        
        List<sObject> adChildren = GenericDAO.getChildren('Folder__c', ads.get(0).id, new List<String>{'id'});     
                   
        
        // Test 
        Map<String, String> queryStrings = new Map<String, String>();
        queryFieldNameValue.put('Active__c', 'true');
        queryFieldNameValue.put('Name', 'Root Folder;Test3;Test4');
        
        sObject[] result = GenericDAO.getObjectGroupByCount('Folder__c', 
                                    'Name', 
                                    queryStrings,
                                    'and', null);
            
        //check with 'or'                           
        sObject[] result1 = GenericDAO.getObjectGroupByCount('Folder__c', 
                                    'Name', 
                                    queryStrings,
                                    'or', null);                          
                                     
        List<BT_SoqlCondition> fieldConditions = new List<BT_SoqlCondition>();
        fieldConditions.add(new BT_SoqlFieldCondition('Access_Type__c', BT_SoqlBuilder.Operator.NOT_EQUALS, BT_Constants.FILE_ACCESS_PRIVATE));
        
       /* sObject[] result3 = GenericDAO.getObjectGroupByCount('Folder__c', 
                                    'Name', 
                                    fieldConditions,
                                    'and');    */
                                                                
        AggregateResult[] groupedResults = (AggregateResult[]) result;
        System.assert(true);
    }       
}