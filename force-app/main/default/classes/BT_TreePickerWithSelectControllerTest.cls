/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: BT_TreePickerWithSelectControllerTest
* Created by Sagar
*
* Test class for BT_TreePickerWithSelectController

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_TreePickerWithSelectControllerTest 
{
    @testSetup static void insertTestData(){
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
        Map<String, Amazon_S3_Key__c> awsCredentials = Amazon_S3_Key__c.getAll();
        System.assertEquals(awsCredentials.size(), 2);
    }
    static testMethod void testController1(){
        Boolean found=false;
        BT_TreePickerWithSelectController controller=new BT_TreePickerWithSelectController();
        
        //test showPopup()
        controller.showPopup();
        System.assert(controller.displayPopup);
        
        //test getDisplayPopupStyle method
        controller.displayPopup=true;
        System.assertEquals('', controller.getDisplayPopupStyle()); 
        controller.displayPopup=false;
        System.assertEquals('display:none', controller.getDisplayPopupStyle());  
        
        //test cancel method
        controller.cancel();
        
        //create treepickernode     
        Account testAccount = new Account(name='testAccount');
        insert testAccount;
        
        TreePickerNode testNode=new TreePickerNode(testAccount.Id,'testAccount');
        //marked as selected
        testNode.checked=true;    
        //create list of treepickernode   
        List<TreePickerNode> testSelectedTreeNodes=new List<TreePickerNode>();
        testSelectedTreeNodes.add(testNode);
        //added one  selected treepickernode
        controller.selectedNodes1=testSelectedTreeNodes;
        
        controller.jsonStringForSelectedNodes = JSON.serialize(new List<TreePickerNode>{});
      
        //testing createLinks method
        PageReference pg = controller.createNodeList();
        
        //test processChecked()
        controller.processChecked();
        System.assert(!controller.displayPopup);
        
        //test removeItems()
        controller.removeItems();       
        If(controller.selectedNodes1!=null)
        {
            found=true;
        }
        System.assert(found);       
    }
    
    static testMethod void testController2()
    {   
        // create folder
        Folder__c testFolder = new Folder__c(name='testFolder');
        insert testFolder;
        
        //create file
        File__c testFile = new File__c(name='testFile', Folder__c = testFolder.Id);
        insert testFile;
        
        BT_TreePickerWithSelectController controller = new BT_TreePickerWithSelectController();
        
        //create tree node and marked as selected and create list of treepickernode
        TreePickerNode testNode = new TreePickerNode(testFile.Id,'testFile');

        testNode.checked = true;    
           

        List<TreePickerNode> testSelectedTreeNodes = new List<TreePickerNode>();
        testSelectedTreeNodes.add(testNode);
        //added one  selected treepickernode
        controller.selectedNodes1 = testSelectedTreeNodes;
        system.assertEquals(controller.selectedNodes1.size(),1);
        
         //testing wrapper class. Adding 1 entry to wrapper class list.
         //creating wrapper class object and creating list<wrapper class>
         BT_TreePickerWithSelectController.sObjectWrapperClass wrapperClassObject = new BT_TreePickerWithSelectController.sObjectWrapperClass(testFile);
         wrapperClassObject.isSelected = true;
         List<BT_TreePickerWithSelectController.sObjectWrapperClass> wrapperClassList = new List<BT_TreePickerWithSelectController.sObjectWrapperClass>();
         wrapperClassList.add(wrapperClassObject);  
         //assigning wrapper class list
         Map<String, List<BT_TreePickerWithSelectController.sObjectWrapperClass>> testMap = new Map<String, List<BT_TreePickerWithSelectController.sObjectWrapperClass>>();
         testMap.put('File__c', wrapperClassList);
         controller.sObjectRecList = testMap;
        
        //Added searchable object
        List<String> searchableObjectList = new List<String>();
        searchableObjectList.add('File__c');
        controller.searchableObject = searchableObjectList;
        
        controller.searchText = 'test';
        controller.doSearch();
        system.assert(controller.displaySearchResult);
        
        controller.processSearched();
        
        controller.searchText = 'bye';
        controller.doSearch();
        controller.processSearched();
        system.assert(!controller.displaySearchResult);
    }
    
    static testMethod void testController3()
    {   
        BT_TreePickerWithSelectController controller=new BT_TreePickerWithSelectController();
        controller.selectedNodes1 = new List<TreePickerNode>();
        //create treepickernode     
        Account testAccount = new Account(name='testAccount');
        insert testAccount;
        
        TreePickerNode testNode=new TreePickerNode(testAccount.Id,'testAccount');
        //marked as selected
        testNode.checked=true;    
        //create list of treepickernode   
        List<TreePickerNode> testSelectedTreeNodes=new List<TreePickerNode>();
        testSelectedTreeNodes.add(testNode);
        //added one  selected treepickernode
        controller.alreadySelectedNodes=testSelectedTreeNodes;
        system.assertEquals(controller.alreadySelectedNodes.size(),1);
        
         controller.processChecked();
    }
}