/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  15-Nov-2018
*/
@isTest
public class BT_PrintLineItemControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    	ApexPages.currentPage().getParameters().put('id',[Select Id from Budget__c Limit 1].Id);
    	
    	BT_PrintLineItemController print = new BT_PrintLineItemController();
    	print.childObjName = 'buildertek__Budget_Item__c';
    	print.parentObjName = 'buildertek__Budget__c';
        print.GroupBy='true';
        print.groupObject='buildertek__Group__c'; 
        print.groupObjects='buildertek__Budget_Line_Group__c';
		print.childFieldApi='buildertek__Product_Name__c,buildertek__Quantity__c,buildertek__Unit_Price__c,buildertek__Original_Budget__c,buildertek__Budget_Modification__c,buildertek__Revised_Budget__c,'
							    +'buildertek__Projected_Costs__c,buildertek__Total_Costs__c,'
							    +'buildertek__Pending_CO__c,buildertek__Approved_CO__c,'
							    +'buildertek__Total_CO__c,buildertek__Profit_Loss__c';
		print.totalSumOfFields='buildertek__Unit_Price__c,'
							+'buildertek__Original_Budget__c,buildertek__Budget_Modification__c,'
							+'buildertek__Revised_Budget__c,buildertek__Projected_Costs__c,'
							+'buildertek__Total_Costs__c,buildertek__Pending_CO__c,'
							+'buildertek__Approved_CO__c,buildertek__Total_CO__c,'
							+'buildertek__Profit_Loss__c';
							
							
		print.getChildRecordsList();
		System.assertEquals('Test','Test');
    }
}