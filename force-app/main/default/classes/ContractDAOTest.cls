/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  15-Nov-2018
*/
@isTest
public class ContractDAOTest {
    @testSetup static void setupBaseData() {  
        // SetupTestData.setupBaseData();
    }
    
//     public static testMethod void test1() {
//         buildertek__Project__c project= Buildertek_UtilityClass.project();
//     //  Project__c proj = [Select Id from Project__c LIMIT 1];
//         Account acc = new Account();
//         acc.Name ='test';
//         insert acc;
        
//         Quote__c quote = [Select Id, Status__c from Quote__c LIMIT 1];
//         quote.Status__c = 'Customer Accepted';
//         quote.Project__c = project.Id;
//         update quote;
        
//         RFQ__c rfq = new RFQ__c();
//         rfq.Name = 'Test';
//         rfq.Project__c = project.Id;
//         insert rfq;
        
//         RFQ_Item__c item = new RFQ_Item__c();
//         item.Name = 'Test';
//         item.RFQ_Package__c = rfq.Id;
//         insert item;
//         buildertek__Contract__c contract = new buildertek__Contract__c();
//         contract.Name='test contract';
//         insert contract;
        
//         List<buildertek__Contract__c> contractLst = new List<buildertek__Contract__c>();
//         //buildertek__Contract__c contract = [Select Id from buildertek__Contract__c LIMIT 1];
//         //contractLst.add(contract);
//         RFQ_To_Vendor__c rfqVendor = new RFQ_To_Vendor__c();
//         rfqVendor.Vendor__c = acc.Id;
//         rfqVendor.RFQ__c = rfq.Id; 
//         insert rfqVendor;
        
//         buildertek__Change_Order__c co = new buildertek__Change_Order__c();
//         co.name = 'Test';
//         co.Project__c = project.Id;
//         co.buildertek__Customer_Account__c =acc.id;
//         insert co;
        
//         List<buildertek__Quote_Line_Group__c> groupListRef = new List<buildertek__Quote_Line_Group__c>();
//         List<buildertek__Quote_Line_Group__c> groupListUpdate = new List<buildertek__Quote_Line_Group__c>();
//         buildertek__Quote_Line_Group__c groupRef = new buildertek__Quote_Line_Group__c();
//         groupRef.Name = 'test';
//         //groupRef.buildertek__Contract__c = contract.id;
//         groupListRef.add(groupRef);
//         insert groupRef;
//         groupListUpdate.add(groupRef);
        
//         Product2 productId = new Product2();
//         productId.Name = 'test';
//         insert productId;
        
//     //  buildertek__Cost_Code__c codeRef = new buildertek__Cost_Code__c();
//     //  codeRef.Name = 'test';
//     //  insert codeRef;
        
//         List<buildertek__Contract_Item__c> bContractListRecUpdate = new List<buildertek__Contract_Item__c>();
//         List<buildertek__Contract_Item__c> bContractListRec = new List<buildertek__Contract_Item__c>();
//         buildertek__Contract_Item__c bContractRec = new buildertek__Contract_Item__c();
//         bContractRec.Name = 'test'; 
//         //bContractRec.buildertek__contract__c = contract.Id;
//         bContractRec.buildertek__Contract_Item_Group__c =groupRef.id;
//         bContractRec.buildertek__Unit_Price__c =20;
//         bContractRec.buildertek__Quantity__c =10;
//         bContractRec.buildertek__Product__c =productId.id;
//         bContractRec.buildertek__Contract__c =contract.id;
//     //  bContractRec.buildertek__Cost_Code__c =codeRef.id;
//         bContractListRec.add(bContractRec);
//         insert bContractRec;
//         bContractListRecUpdate.add(bContractRec);
        
//         map<Id,buildertek__RFQ__c> MapRfqRec =new map<Id,buildertek__RFQ__c>();
//         buildertek__RFQ__c RfqRef = new buildertek__RFQ__c();
//         RfqRef.buildertek__Description__c ='test';
//         RfqRef.buildertek__Project__c =project.id;
//         insert RfqRef;
//         MapRfqRec.put(RfqRef.id,RfqRef);

//         buildertek__RFQ_Item__c RFQRec = new buildertek__RFQ_Item__c();
//         RFQRec.Name ='test';
//         RFQRec.buildertek__RFQ_Package__c =RfqRef.id;
//         insert RFQRec;
        
//         //ContractDAO.GetContractLines(contract.Id);
//         ContractDAO.GetContractLines(bContractRec.id);
//        // ContractDAO.updateLineFromDataTable(JSON.serialize(bContractListRecUpdate),null,contract.Id);
//         ContractDAO.getProduct(JSON.serialize(bContractListRecUpdate));
//         ContractDAO.addProductsToList(JSON.serialize(bContractListRecUpdate),bContractListRecUpdate[0],1);
//     //--    ContractDAO.getQuoteGroupDetails(contract.Id,null,10,0);
//         ContractDAO.fillContractItemFromRFQItem(bContractRec,RFQRec);
//         ContractDAO.createSubContractFromRFQ(MapRfqRec);
//     //  ContractDAO.createSubContract(contract,'bContractRec');2
//         ContractDAO.getContractTemplates();
//         ContractDAO.getFields();
//         ContractDAO.GetGroupedContractLines(bContractRec.id);
//         ContractDAO.getProductPrice(productId.id);
//     //  ContractDAO.saveContractLineItem(bContractRec);
//     //  ContractDAO.deleteContractLineItem(bContractRec.id);
//     //--    ContractDAO.retrieveGroups(bContractRec.id, 1, 10);
//     //  updateLineFromDataTable
//         ContractDAO.getFieldSet('fieldSetName','buildertek__Contract_Item__c');
//         ContractDAO.updateGroupsOrder(groupListRef);
//         ContractDAO.deleteGroups(groupListRef);
//     //  ContractDAO.deleteItem(groupListRef,'');
//     //  ContractDAO.createContractItem('contractItemsJSON');
//     //  ContractDAO.getcontractItem(bContractRec.id);
//     //  ContractDAO.updatecontractLineItem(bContractListRec);
//         Account originalValue=new Account();
//         ContractDAO.RecordsList RecordsList = new ContractDAO.RecordsList(true ,'recordValue','fieldName',originalValue, 'fieldType');
//         ContractDAO.contractDetails ContractDetailsRef = new ContractDAO.contractDetails();
//         ContractDAO.contractClass contractClassRef = new ContractDAO.contractClass();
//         ContractDAO.ContractLineWrapper ContractLineWrapperRef = new ContractDAO.ContractLineWrapper();
//     //  ContractDAO.fieldSet fieldSetRef = new ContractDAO.fieldSet();
       
//         System.assertEquals('Test','Test');
//     }
//     public static testMethod void test2() {
//         buildertek__Project__c project= Buildertek_UtilityClass.project();
//     //  Project__c proj = [Select Id from Project__c LIMIT 1];
//         Account acc = new Account();
//         acc.Name ='test';
//         insert acc;
        
//         Quote__c quote = [Select Id, Status__c from Quote__c LIMIT 1];
//         quote.Status__c = 'Customer Accepted';
//         quote.Project__c = project.Id;
//         update quote;
        
//         RFQ__c rfq = new RFQ__c();
//         rfq.Name = 'Test';
//         rfq.Project__c = project.Id;
//         insert rfq;
        
//         RFQ_Item__c item = new RFQ_Item__c();
//         item.Name = 'Test';
//         item.RFQ_Package__c = rfq.Id;
//         insert item;
        
//         //buildertek__Contract__c contract = [Select Id from buildertek__Contract__c LIMIT 1];
        
//         RFQ_To_Vendor__c rfqVendor = new RFQ_To_Vendor__c();
//         rfqVendor.Vendor__c = acc.Id;
//         rfqVendor.RFQ__c = rfq.Id;
//         insert rfqVendor;
        
//         buildertek__Change_Order__c co = new buildertek__Change_Order__c();
//         co.name = 'Test';
//         co.Project__c = project.Id;
//         co.buildertek__Customer_Account__c =acc.id;
//         insert co;
        
//         buildertek__Contract__c contract = new buildertek__Contract__c();
//         contract.Name='test contract';
//         insert contract;
        
//         List<Quote_Line_Group__c> groupListRef = new List<Quote_Line_Group__c>();
//         Quote_Line_Group__c groupRef = new buildertek__Quote_Line_Group__c();
//         groupRef.Name = 'test';
//         //groupRef.buildertek__Contract__c = contract.id;
//         groupListRef.add(groupRef);
//         insert groupRef;
        
//         List<buildertek__Contract_Item__c> bContractListRec = new List<buildertek__Contract_Item__c>();
//         buildertek__Contract_Item__c bContractRec = new buildertek__Contract_Item__c();
//         bContractRec.Name = 'Sample Quote Item'; 
//         bContractRec.buildertek__contract__c = contract.Id;
//         bContractRec.buildertek__Contract_Item_Group__c =groupRef.id;
//         bContractListRec.add(bContractRec);
//     //  insert bContractRec;
//     //  insert bContractListRec;
//         List<buildertek__Contract_Item__c> bContractList1Rec = new List<buildertek__Contract_Item__c>();
//         buildertek__Contract_Item__c bContractRec1 = new buildertek__Contract_Item__c();
//         bContractRec1.Name = 'Sample Quote Item'; 
//         bContractRec1.buildertek__contract__c = contract.Id;
//         bContractRec1.buildertek__Contract_Item_Group__c =groupRef.id;
//         bContractListRec.add(bContractRec1);
        
//         buildertek__RFQ__c RfqRef = new buildertek__RFQ__c();
//         RfqRef.buildertek__Description__c ='test';
//         RfqRef.buildertek__Project__c =project.id;
//         insert RfqRef;
        
//         buildertek__RFQ_Item__c RFQRec = new buildertek__RFQ_Item__c();
//         RFQRec.Name ='test';
//         RFQRec.buildertek__RFQ_Package__c =RfqRef.id;
//         insert RFQRec;
        
//         String ContractJson = JSON.serialize(bContractRec);
        
//         //ContractDAO.GetContractLines(contract.Id);
//         ContractDAO.GetContractLines(bContractRec.id);
//     //  ContractDAO.getQuoteGroupDetails(contract.Id,null, 10, 0);
//         ContractDAO.fillContractItemFromRFQItem(bContractRec,RFQRec);
//     //  ContractDAO.createSubContract(contract,'Sub Contract');
//         ContractDAO.getContractTemplates();
//         ContractDAO.getFields();
//         ContractDAO.GetGroupedContractLines(bContractRec.id);
//     //  getProductPrice
//         ContractDAO.saveContractLineItem(ContractJson); 
//     //  ContractDAO.deleteContractLineItem(bContractRec.id);
//     //--    ContractDAO.retrieveGroups(bContractRec.id, 1, 10);
//     //  updateLineFromDataTable
//         ContractDAO.getFieldSet('fieldSetName','buildertek__Contract_Item__c');
//         ContractDAO.updateGroupsOrder(groupListRef);
//     //  ContractDAO.deleteGroups(groupRef);
//     //  deleteItem
//     //  ContractDAO.createContractItem('contractItemsJSON');
//     //  ContractDAO.getcontractItem(bContractListRec[0].id);
//         insert bContractRec1;
//         ContractDAO.updatecontractLineItem(bContractRec1);
//         ContractDAO.contractDetails ContractDetailsRef = new ContractDAO.contractDetails();
//         System.assertEquals('Test','Test');
//     }
//     public static testMethod void test3() {
//         buildertek__Contract__c contractRec = new buildertek__Contract__c();
//         contractRec.Name = 'TEst';
//         insert contractRec;
        
//         List<buildertek__Quote_Line_Group__c> groupListRef = new List<buildertek__Quote_Line_Group__c>();
//         buildertek__Quote_Line_Group__c groupRef = new buildertek__Quote_Line_Group__c();
//         groupRef.Name = 'test';
//         //groupRef.buildertek__Contract__c = contractRec.id;
//         groupListRef.add(groupRef);
//         insert groupRef;
        
//         buildertek__Contract__c contractRef = new buildertek__Contract__c();
//         contractRef.Name = 'test';
//         contractRef.Signed_Contract_Date__c = System.today();
// //      insert contractRef;
//         String myJSONDAO = JSON.serialize(contractRef);
        
//         List<buildertek__Contract_Item__c> bContractListRec = new List<buildertek__Contract_Item__c>();
//         buildertek__Contract_Item__c bContractRec1 = new buildertek__Contract_Item__c();
//         bContractRec1.Name = 'Sample Quote Item'; 
//         bContractRec1.buildertek__contract__c = contractRef.Id;
//         bContractRec1.buildertek__Contract_Item_Group__c =groupRef.id;
//         bContractListRec.add(bContractRec1);
//         String myJSONDAOItem = JSON.serialize(bContractListRec);
        
//         ContractDAO.createSubContract(myJSONDAO,myJSONDAOItem);
//         System.assertEquals('Test','Test');
//      }
    
//     public static testMethod void test4() {
        
//         buildertek__Quote_Line_Group__c groupRef = new buildertek__Quote_Line_Group__c();
//         groupRef.Name = 'test';
//         insert groupRef;
//         System.assert(groupRef.Id!=null);
        
//         buildertek__Contract__c contract = new buildertek__Contract__c();
//         contract.Name='test contract';
//         insert contract;
//         System.assert(contract.Id!=null);
        
//         buildertek__Contract__c contract1 = new buildertek__Contract__c();
//         contract1.Name='test contract';
        
//         contract_Item__c contractItem1 = new contract_Item__c();
//         contractItem1.name='test';
//         contractItem1.buildertek__Contract__c=contract.Id;
//         insert contractItem1;
//         System.assert(contractItem1.Id!=null);
        
//         contract_Item__c contractItem2 = new contract_Item__c();
//         contractItem2.name='test';
//         contractItem2.buildertek__Contract__c=contract.Id;
//         insert contractItem2;
//         System.assert(contractItem2.Id!=null);
        
//         List<String> contractItemIdLst = new List<String>();
//         contractItemIdLst.add(contractItem2.Id);
        
//         Product2 productId = new Product2();
//         productId.Name = 'test';
//         insert productId;
//         System.assert(productId.Id!=null);
        
        
//         buildertek__Contract_Item__c bContractRec = new buildertek__Contract_Item__c();
//         bContractRec.Name = 'test'; 
//         bContractRec.buildertek__contract__c = contract.Id;
//         bContractRec.buildertek__Contract_Item_Group__c =groupRef.id;
//         bContractRec.buildertek__Unit_Price__c =20;
//         bContractRec.buildertek__Quantity__c =10;
//         bContractRec.buildertek__Product__c =productId.id;
//         insert bContractRec;
//         System.assert(bContractRec.Id!=null);
        
//         List<buildertek__Contract_Item__c> bContractListRec = new List<buildertek__Contract_Item__c>();
//         bContractListRec.add(bContractRec);
        
//         buildertek__Contract_Item__c bContractRec1 = new buildertek__Contract_Item__c();
//         bContractRec1.Name = 'test'; 
//         bContractRec1.buildertek__contract__c = contract.Id;
//         bContractRec1.buildertek__Contract_Item_Group__c =groupRef.id;
//         bContractRec1.buildertek__Unit_Price__c =20;
//         bContractRec1.buildertek__Quantity__c =10;
//         bContractRec1.buildertek__Product__c =productId.id;
        
//         buildertek__Contract_Item__c bContractRec2 = new buildertek__Contract_Item__c();
//         bContractRec2.Name = 'test'; 
//         bContractRec2.buildertek__contract__c = contract.Id;
//         //bContractRec2.buildertek__Contract_Item_Group__c =groupRef.id;
//         bContractRec2.buildertek__Unit_Price__c =20;
//         bContractRec2.buildertek__Quantity__c =10;
//         bContractRec2.buildertek__Product__c =productId.id;
        
//         buildertek__Contract_Item__c bContractRec3 = new buildertek__Contract_Item__c();
//         bContractRec3.Name = 'test'; 
//         bContractRec3.buildertek__contract__c = contract.Id;
//         bContractRec3.buildertek__Contract_Item_Group__c =groupRef.id;
//         bContractRec3.buildertek__Unit_Price__c =20;
//         bContractRec3.buildertek__Quantity__c =10;
//         bContractRec3.buildertek__Product__c =productId.id;
//         insert bContractRec3;
//         System.assert(bContractRec3.Id!=null);
        
//         bContractRec3.Name='test update';
        
//         List<buildertek__Contract_Item__c> bContractListRec1 = new List<buildertek__Contract_Item__c>();
//         bContractListRec1.add(bContractRec1);
        
//         List<buildertek__Contract_Item__c> bContractListRec2 = new List<buildertek__Contract_Item__c>();
//         bContractListRec2.add(bContractRec2);
        
//         List<buildertek__Contract_Item__c> bContractListRec3 = new List<buildertek__Contract_Item__c>();
//         bContractListRec3.add(bContractRec3);
        
//         buildertek__Contract_Item__c bContractRec4 = new buildertek__Contract_Item__c();
//         bContractRec4.Name = 'test'; 
//         bContractRec4.buildertek__contract__c = contract.Id;
//         bContractRec4.buildertek__Contract_Item_Group__c =groupRef.id;
//         bContractRec4.buildertek__Unit_Price__c =20;
//         bContractRec4.buildertek__Quantity__c =10;
//         bContractRec4.buildertek__Product__c =productId.id;        
        
//         String contractItemsJSON=JSON.serialize(bContractListRec1);
//         String contractItemsJSON2=JSON.serialize(bContractListRec2);
//         String contractItemsJSON3=JSON.serialize(bContractListRec3); 
        
//         String result='';
//         result=ContractDAO.createContractItem(contractItemsJSON2);
//         System.assertEquals('Success',result);
        
//         result=ContractDAO.createContractItem(contractItemsJSON);
//         System.assertEquals('Success',result);
         
//         contract_Item__c contractItemRec= ContractDAO.getcontractItem(contractItem1.Id);
//         System.assertEquals(contractItemRec.Id, contractItem1.Id);
        
//         List<buildertek__Contract_Item__c> contractItemRecs=ContractDAO.prepareString(contractItemsJSON); 
        
//         ContractDAO.saveUpdatedValues(bContractListRec3);
        
//         ContractDAO.getpricebooks(); 
        
//         result=ContractDAO.getpricebook(contract.Id); 
        
//         ContractDAO.setDefaultGrouping(bContractListRec3);
        
//         List<String> allFields = new List<String>{'Id', 'buildertek__Contract_Line_Group__c', 'buildertek__Quantity__c', 'buildertek__Unit_Price__c'};
            
//             //String fieldString;
//             String fieldString = '[{"fieldName":"buildertek__Contract_Line_Group__c","fieldType":"reference","isEditable": false},'
//             +'{"fieldName":"Id","fieldType":"","isEditable": false},'
//             +'{"fieldName":"buildertek__Quantity__c","fieldType":"number","isEditable": true},'
//             +'{"fieldName":"buildertek__Unit_Price__c","fieldType":"currency","isEditable": true}]';
         
//        // ContractDAO.getQuoteItemData(contract.Id, allFields, fieldString, 10, 0);
//         ContractDAO.ContractLineItemsClass cli= new ContractDAO.ContractLineItemsClass(bContractRec4,true,1);
//         List<ContractDAO.ContractLineItemsClass> cliLst= new List<ContractDAO.ContractLineItemsClass>();
//         cliLst.add(cli);
//         ContractDAO.createSubContractFromBudget(contract1,JSON.serialize(cliLst));
        
//         ContractDAO.massUpdateContractLineItem(contractItemsJSON3);
//        // ContractDAO.duplicateContractLineItem(contractItemIdLst);
//         ContractDAO.deleteQuoteItem(contractItem1.Id);
//         ContractDAO.deleteSelectedItems(contractItemIdLst);
//        //-- ContractDAO.deleteItem(bContractListRec, groupRef.Id, contract.Id);
        
//         buildertek__Contract_Item__c bContractRec5 = new buildertek__Contract_Item__c();
//         bContractRec5.Name = 'test'; 
//         bContractRec5.buildertek__contract__c = contract.Id;
//         bContractRec5.buildertek__Unit_Price__c =20;
//         bContractRec5.buildertek__Quantity__c =10;
//         bContractRec5.buildertek__Product__c =productId.id;
//         insert bContractRec5;
        
//         ContractDAO.saveContractLineItem(JSON.serialize(bContractRec5)); 
//         System.assert(bContractRec5.Id!=null);   
//     }
}