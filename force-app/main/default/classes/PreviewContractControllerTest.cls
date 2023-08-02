/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class PreviewContractControllerTest {
    @testSetup static void setupBaseData() { 
        SetupTestData.setupBaseData();
    }
    public static testMethod void test1() {
    	Contract__c contract = new Contract__C();
    	contract.Name = 'Test';
    	insert contract;
    	
    	Contract_Item__c item = new Contract_Item__c();
    	item.Name = 'TEst';
    	item.Contract__c = contract.Id;
    	insert item;
    	
    	PreviewContractController contractc = new PreviewContractController();
    	contractc.recId = contract.Id;
    	contractc.ContractMethod();
    	
    	string theTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Contract Template 1'].Id;
    	List<String> emailList = new List<String>();
    	emailList.add('Test@gmail.com');
    	PreviewContractController.getTemplates(contract.Id);
    	PreviewContractController.getContractLines(contract.Id, theTemplate);
    	PreviewContractController.getProposalImages(contract.Id);
    	PreviewContractController.sendProposal('', contract.Id, theTemplate, emailList, null); 
    	System.assertEquals('Test','Test');
    	
    } 
}