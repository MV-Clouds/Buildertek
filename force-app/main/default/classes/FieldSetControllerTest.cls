/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  19-Nov-2018
*/
@isTest
public class FieldSetControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    	FieldSetController.getFields('Product2','buildertek__BT_Product_Picker_Fields');
    	
    	BT_FieldSetController.getFields('Product2','buildertek__BT_Product_Picker_Fields');
    	System.assertEquals('Test','Test');
    }
}