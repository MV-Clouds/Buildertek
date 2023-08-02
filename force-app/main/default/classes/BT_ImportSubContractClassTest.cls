@isTest
public  class BT_ImportSubContractClassTest {
    @isTest static void testMethod1(){

        Account account1 = new Account(
            Name = 'Test'
        );
        insert account1;
        Contact contact1 = new Contact(
            AccountId = account1.Id,
            LastName = 'LastName1',
            email='sagar@buildertek.com'
        );
        insert contact1;
        buildertek__Project__c project = new buildertek__Project__c(
            Name = 'Sample Project',
            buildertek__Account__c = account1.Id,
            buildertek__Project_Manager__c = UserInfo.getUserId(),
            Project_Tax_Rate__c = 10.5
        );
        insert project;
        buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c(
        buildertek__Contractor_Resource__c = contact1.Id,
        buildertek__Vendor__c = account1.Id,
        buildertek__Project__c = project.Id,
        buildertek__Ship_To_Address__c = account1.Id);
        insert purchaseOrder;

        buildertek__Cost_Codes__c codeRef = new buildertek__Cost_Codes__c();
        codeRef.Name = 'Test';
        insert codeRef;



        Id contractRecordTypeId = Schema.SObjectType.buildertek__Contract__c.getRecordTypeInfosByName().get('Sub Contract').getRecordTypeId();
       List<String> contractIdList = new List<String>();
       List<buildertek__Contract__c> contractList= new List<buildertek__Contract__c>();

        buildertek__Contract__c cont = new buildertek__Contract__c();
        cont.Name = 'Test Contract';
        cont.buildertek__Type__c='Master';
        cont.buildertek__Signed_Contract_Date__c=Date.Today();
        cont.RecordTypeId=contractRecordTypeId;
        cont.buildertek__Cost_Code__c=codeRef.Id;
        cont.buildertek__Vendor__c=account1.Id;
        insert cont;

        buildertek__Contract__c cont2 = new buildertek__Contract__c();
        cont2.Name = 'Test Contract2';
        cont2.buildertek__Type__c='Master';
        cont2.buildertek__Signed_Contract_Date__c=Date.Today();
        cont2.RecordTypeId=contractRecordTypeId;
        cont2.buildertek__Cost_Code__c=codeRef.Id;
        cont2.buildertek__Vendor__c=account1.Id;
        insert cont2;

        buildertek__Quote_Line_Group__c groupRef = new buildertek__Quote_Line_Group__c();
        groupRef.Name = 'test';
        insert groupRef;

       
        buildertek__Contract_Item__c bContractRec = new buildertek__Contract_Item__c();
        bContractRec.Name = 'test'; 
        bContractRec.buildertek__contract__c = cont.Id;
        bContractRec.buildertek__Contract_Item_Group__c =groupRef.id;
        bContractRec.buildertek__Unit_Price__c =20;
        bContractRec.buildertek__Quantity__c =10;
        insert bContractRec;
            


        contractIdList.add(cont.Id);
        contractIdList.add(cont2.Id);

        contractList.add(cont);
        contractList.add(cont2);


        BT_ImportSubContractClass.getMasterBudgets();
        BT_ImportSubContractClass.importSubContractItems(contractIdList , purchaseOrder.Id );
        BT_ImportSubContractClass.findByName('Test' , purchaseOrder.Id );
        BT_ImportSubContractClass.findByName1('Test' , purchaseOrder.Id );
        BT_ImportSubContractClass.findByName2('Test' , purchaseOrder.Id );





    }
}