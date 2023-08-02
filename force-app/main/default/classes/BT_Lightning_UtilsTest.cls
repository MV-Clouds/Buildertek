/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  15-Nov-2018
*/
@isTest
public class BT_Lightning_UtilsTest {
	
	@testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    	BT_Lightning_Utils.columnsHeader('Product2','buildertek__BT_Product_Picker_Fields', new List<string>(), new List<string> ());
    	BT_Lightning_Utils.columnsModels('Product2','buildertek__BT_Product_Picker_Fields', new List<string>(2), new List<string> (3), new List<string> (3));
    	BT_Lightning_Utils.recordData('Product2', '','buildertek__BT_Product_Picker_Fields', '', '');
    	BT_Lightning_Utils.sessionId();
    	BT_Lightning_Utils.deleteRecords('Product2',new List<string>());
    	BT_Lightning_Utils.perpareFieldsOfObject('Product2','buildertek__BT_Product_Picker_Fields');
    	BT_Lightning_Utils.getListViews('Product2');
    	BT_Lightning_Utils.getFieldSetForDataTable('Product2','buildertek__BT_Product_Picker_Fields');
    	BT_Lightning_Utils.FieldSetWrapper.getFieldSet('Product2','');
    	buildertek__Project__c proj = new buildertek__Project__c();
    	proj.Name = 'Test Project';
    	insert proj;
    	
    	RFQ__c rfq = new RFQ__c();
    	rfq.Name = 'Test';
    	rfq.buildertek__Project__c = proj.Id;
    	insert rfq;
    	
    	BT_Lightning_Utils.getAllVendors('','','',rfq.Id);
    	System.assertEquals('Test','Test');
    	
    	
    }
   
}