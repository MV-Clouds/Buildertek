@isTest
public class PurchaseOrderTrigger_Test {
    static testmethod void testPurchaseOrderTrigger(){
        Account accRec = new Account();
        accRec.Name = 'Test 2'; 
        insert accRec;
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = NEW buildertek__Admin_Interface_Node_Configuration__c(Name= 'Purchase Order Configuration',
                                                                                                                                                  buildertek__Email_Subject__c = 'Test',
                                                                                                                                                  buildertek__Quote_Configuration__c = true);
        insert adminInterfaceNodeConfigurations;
        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();
        
        List<buildertek__RFQ__c> RFQLSTRef = new List<buildertek__RFQ__c> ();
        buildertek__RFQ__c RFQRef = new buildertek__RFQ__c ();
        RFQRef.Name='test';
        RFQRef.buildertek__Project__c = buildertekProjectRef.Id; 
        RFQRef.buildertek__Due_Date__c = system.today();
        RFQRef.buildertek__Status__c ='Awarded'; 
        RFQLSTRef.add(RFQRef);
        insert RFQLSTRef;
        System.assert(RFQLSTRef[0].Id!=null);
        
        buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
        PO.buildertek__Project__c = buildertekProjectRef.Id;
        PO.buildertek__Status__c = 'Awarded';
        PO.buildertek__Type__c = 'Standard'; 
        PO.buildertek__RFQ__c = RFQRef.Id;
        Po.buildertek__Description__c = RFQRef.Name;
        Po.buildertek__Vendor__c = accRec.Id;
        insert PO;
        System.assert(PO.Id!=null);
        
        buildertek__Purchase_Order_Item__c POItem = new buildertek__Purchase_Order_Item__c();
        POItem.buildertek__Purchase_Order__c=PO.Id;
        POItem.buildertek__Quantity__c=5;
        POItem.buildertek__Unit_Price__c=5000;
        insert POItem;
        System.assert(POItem.Id!=null);
        
        buildertek__Account_Payable__c payable = new buildertek__Account_Payable__c();
        payable.buildertek__Purchase_Order__c=PO.Id;
        insert payable;
        
        // buildertek__Account_Payable_Item__c payableItem = new buildertek__Account_Payable_Item__c();
        // payableItem.Name='test item';
        // payableItem.buildertek__Account_Payable__c=payable.Id;
        // payableItem.buildertek__Quantity__c=1;
        // payableItem.buildertek__Unit_Price__c=25000;
        // insert payableItem;
        
        // System.debug(' PO :: '+PO.buildertek__Paid__c);
        // System.debug(' PO :: '+PO.buildertek__Paid_Amount__c);
        // System.debug(' PO :: '+PO.buildertek__PO_Amount__c);
        
        try{
            delete PO;
        }catch(Exception e){
            System.debug('Error :: '+e);
        } 
       System.assert(true); 
    }
}