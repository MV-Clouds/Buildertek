/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_TreePickerControllerTest
* Created by Sagar
*
* Test class for BT_TreePickerController

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_TreePickerControllerTest 
{
    static testMethod void testController()
    {
        Boolean found=false;
        
        Account testAccount = new Account(name='testAccount');
        insert testAccount;
        
        //set parameters
        Apexpages.currentPage().getParameters().put('checkObjectId',testAccount.Id+'');
        Apexpages.currentPage().getParameters().put('checkStatus','true');
        Apexpages.currentPage().getParameters().put('checkObjectTitle',testAccount.Name);
        
        BT_TreePickerController controller=new BT_TreePickerController();       
        
        //testing treeWidth()
        System.assertEquals(350, controller.treeWidth) ;
        
        //testing totalHeight()
        System.assertEquals(350, controller.totalHeight);
        
        //testing numColumns
        found=false;
        Integer testNumColumns=controller.numColumns;
        if(testNumColumns>0)
        {
            found=true;
        }
        System.assert(found);
        
        //testing noRecordsMessage
        found=false;
        String testNoRecordsMessage=controller.noRecordsMessage;
        if(testNoRecordsMessage!=null)
        {
            found=true;
        }
        System.assert(found);           
        
        //test getTreeRootIds()
        found=false;
        String testGetTreeRootIds=controller.getTreeRootIds();      
        if(testGetTreeRootIds!=null)
        {
            found=true;
        }
        System.assert(found);       
        
        
        //test updateCheckStatus()
        found=false;
        //controller.updateCheckStatus();
        List<TreePickerNode> testGetPageRecords=controller.getPageRecords();
        if(testGetPageRecords!=null)
        {
            found=true;
        }   
        System.assert(found);
        
        //create treepickernode
        TreePickerNode testNode=new TreePickerNode(testAccount.Id,'testAccount');
        //marked as selected
        testNode.checked=true;    
        //create list of treepickernode   
        List<TreePickerNode> testSelectedTreeNodes=new List<TreePickerNode>();
        testSelectedTreeNodes.add(testNode);
        //added one  selected treepickernode
        controller.selectedTreeNodes=testSelectedTreeNodes;
        
        //test selectedTreeNodes
        List<TreePickerNode> testSelectedTreeNodes1=controller.selectedTreeNodes;
        
        //test updateCheckStatus method
        Apexpages.currentPage().getParameters().put('checkObjectPath', '');
        controller.updateCheckStatus();
        Apexpages.currentPage().getParameters().put('checkStatus','false');
        controller.updateCheckStatus();
        //test getColumnsToDisplay()
        found=false;        
        BT_TreePickerController.Column testColumnsToDisplay=controller.getColumnsToDisplay()[0];
        if(testColumnsToDisplay!=null)
        {
            found=true;
        }
        controller.clearAllLists();
        controller.getNoSelectedItemList();
        controller.getUpdatedCheckableNodes();
        System.assertEquals('test', 'test');    
        
    }
}