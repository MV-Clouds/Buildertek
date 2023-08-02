/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class BT_GeneratePDFTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    	BT_GeneratePDF pdf = new BT_GeneratePDF();
    	Apexpages.currentPage().getParameters().put('recordId', [Select Id from Purchase_Order__c LIMIT 1].Id);
    	apexpages.currentPage().getParameters().put('templateId', [Select Id from EmailTemplate Where folder.name = 'BT PO' LIMIT 1].Id);
    	pdf.createPDF();
    	System.assertEquals('Test','Test');
    }
}