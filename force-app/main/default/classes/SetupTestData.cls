public with sharing class SetupTestData {
    public static void setupBaseData() {
        Account account1 = new Account(
            Name = 'Sample Account 1'
        );
         if(Schema.sObjectType.Account.isCreateable()&&
            Schema.sObjectType.Account.fields.Name.isCreateable() ){
            insert account1;
            }
        Contact contact1 = new Contact(
            AccountId = account1.Id,
            LastName = 'LastName1',
            email='sagar@buildertek.com'
        );
        
            insert contact1;
			
        
       Opportunity opportunity1 = new Opportunity(
            Name = 'Sample Opportunity 1',
            AccountId = account1.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1)
        );
        if(Schema.sObjectType.Opportunity.isCreateable()&&
            Schema.sObjectType.Opportunity.fields.Name.isCreateable()&&
            Schema.sObjectType.Opportunity.fields.AccountId.isCreateable() &&
			Schema.sObjectType.Opportunity.fields.StageName.isCreateable() &&
			Schema.sObjectType.Opportunity.fields.CloseDate.isCreateable() ){
            insert opportunity1;
			}
        
        Product2 product = new Product2(Name = 'Laptop X200', Family = 'Hardware');
         if(Schema.sObjectType.Product2.isCreateable()&&
            Schema.sObjectType.Product2.fields.Name.isCreateable()&&
            Schema.sObjectType.Product2.fields.Family.isCreateable() ){
            Insert product;
            }
        
       buildertek__Inventory_Management__c inventoryMgmt = new buildertek__Inventory_Management__c(
            buildertek__Product_Id__c = 'Test123',
            buildertek__Product_Name__c = product.Id
        );
        if(Schema.sObjectType.buildertek__Inventory_Management__c.isCreateable()&&
            Schema.sObjectType.buildertek__Inventory_Management__c.fields.buildertek__Product_Id__c.isCreateable()&&
            Schema.sObjectType.buildertek__Inventory_Management__c.fields.buildertek__Product_Name__c.isCreateable() ){
            insert inventoryMgmt;
			}
         RecordType serviceReqType;
        if(Schema.sObjectType.RecordType.fields.Id.isAccessible()&&
            Schema.sObjectType.RecordType.fields.Name.isAccessible()&&
            Schema.sObjectType.RecordType.fields.sObjectType.isAccessible()  ){
            serviceReqType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'buildertek__Service_Request__c' AND IsActive = TRUE LIMIT 1];
            }
        buildertek__Service_Request__c serviceRequest = new buildertek__Service_Request__c(
            RecordTypeId = serviceReqType.Id,
            buildertek__Customer_Name__c = contact1.Id,
            buildertek__Subject__c = 'Sample Subject'
        );
        if(Schema.sObjectType.buildertek__Service_Request__c.isCreateable()&&
            Schema.sObjectType.buildertek__Service_Request__c.fields.RecordTypeId.isCreateable()&&
            Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Customer_Name__c.isCreateable() &&
			Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Subject__c.isCreateable()){
            insert serviceRequest;
			}
        
        buildertek__Product__c bTekProduct = new buildertek__Product__c(
            buildertek__Product__c = inventoryMgmt.Id,
            buildertek__Service_Request__c = serviceRequest.Id,
            buildertek__Product_Name__c = 'Sample Product'
        );
        if(Schema.sObjectType.buildertek__Product__c.isCreateable()&&
            Schema.sObjectType.buildertek__Product__c.fields.buildertek__Product__c.isCreateable()&&
            Schema.sObjectType.buildertek__Product__c.fields.buildertek__Service_Request__c.isCreateable() &&
			Schema.sObjectType.buildertek__Product__c.fields.buildertek__Product_Name__c.isCreateable()){
            insert bTekProduct;
			}
        buildertek__Project__c project = new buildertek__Project__c(
            Name = 'Sample Project',
            buildertek__Account__c = account1.Id,
            buildertek__Opportunity__c = opportunity1.Id,
            buildertek__Project_Manager__c = UserInfo.getUserId(),
            Project_Tax_Rate__c = 10.5
        );
        if(Schema.sObjectType.buildertek__Project__c.isCreateable()&&
            Schema.sObjectType.buildertek__Project__c.fields.Name.isCreateable()&&
            Schema.sObjectType.buildertek__Project__c.fields.buildertek__Account__c.isCreateable() &&
			Schema.sObjectType.buildertek__Project__c.fields.buildertek__Opportunity__c.isCreateable() &&
			Schema.sObjectType.buildertek__Project__c.fields.buildertek__Project_Manager__c.isCreateable() &&
			Schema.sObjectType.buildertek__Project__c.fields.Project_Tax_Rate__c.isCreateable()){
            insert project;
			}
        
        buildertek__Quote__c quote = new buildertek__Quote__c(
            Name = 'Sample Quote',
            buildertek__Opportunity__c = opportunity1.Id,
            buildertek__Primary_Contact__c = contact1.Id,
            buildertek__Product__c = bTekProduct.Id,
            buildertek__Project__c = project.id
        );
        if(Schema.sObjectType.buildertek__Quote__c.isCreateable()&&
            Schema.sObjectType.buildertek__Quote__c.fields.Name.isCreateable()&&
            Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Opportunity__c.isCreateable() &&
			Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Primary_Contact__c.isCreateable() &&
			Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Product__c.isCreateable() &&
			Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Project__c.isCreateable()){
            insert quote;
			}
        
        buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c(
        	Name = 'Sample Quote Item',
            buildertek__Quote__c = quote.Id,
            buildertek__Vendor__c = account1.Id,
            Product__c = product.Id
        );
        if(Schema.sObjectType.buildertek__Quote_Item__c.isCreateable()&&
            Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable()&&
            Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable() &&
			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Vendor__c.isCreateable() &&
			Schema.sObjectType.buildertek__Quote_Item__c.fields.Product__c.isCreateable() ){
            insert quoteItem;
			}
        
           List<buildertek__Purchase_Order__c> poList = new List<buildertek__Purchase_Order__c>();
           buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c(
            buildertek__Contractor_Resource__c = contact1.Id,
            buildertek__Vendor__c = account1.Id,
            buildertek__Project__c = project.Id,
            buildertek__Ship_To_Address__c = account1.Id
        );
        poList.add(purchaseOrder);
        if(Schema.sObjectType.buildertek__Purchase_Order__c.isCreateable()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Contractor_Resource__c.isCreateable()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isCreateable() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isCreateable() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Ship_To_Address__c.isCreateable() ){
            insert poList;
			}
        system.debug('poList --------> '+poList);
        buildertek__Purchase_Order_Item__c purchaseOrderItem = new buildertek__Purchase_Order_Item__c(
            Name = 'Sample Purchase Order Item',
            buildertek__Purchase_Order__c = purchaseOrder.Id,
            buildertek__Product__c = product.Id
        );
         if(Schema.sObjectType.buildertek__Purchase_Order_Item__c.isCreateable()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Name.isCreateable()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Purchase_Order__c.isCreateable() &&
			Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Product__c.isCreateable() ){
            insert purchaseOrderItem;
			}
        
        buildertek__Budget__c budget = new buildertek__Budget__c(
            Name = 'Sample Budget',
            buildertek__Type__c = 'Standard',
            buildertek__Project__c = project.Id
        );
        if(Schema.sObjectType.buildertek__Budget__c.isCreateable()&&
            Schema.sObjectType.buildertek__Budget__c.fields.Name.isCreateable()&&
            Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Type__c.isCreateable() &&
			Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isCreateable() ){
            insert budget;
			}
    }
    
    public static Account createAccount(){
        Account account1 = new Account(
            Name = 'Sample Account 1'
        );
        if(Schema.sObjectType.Account.isCreateable()&&
            Schema.sObjectType.Account.fields.Name.isCreateable() ){
        insert account1;
        } 
        return account1;
    }
    
    public static Contact createContact(Account accId){
        Contact contact1 = new Contact(
            AccountId = accId.Id,
            LastName = 'LastName1',
            email='sagar@buildertek.com'
        );
        if(Schema.sObjectType.Contact.isCreateable()&&
            Schema.sObjectType.Contact.fields.AccountId.isCreateable()&&
            Schema.sObjectType.Contact.fields.LastName.isCreateable() &&
			Schema.sObjectType.Contact.fields.email.isCreateable()  ){
            insert contact1;
		}  
		return contact1;
    }
    
    public static buildertek__Project__c createProj(Account accId){
        buildertek__Project__c project = new buildertek__Project__c(
            Name = 'Sample Project',
            buildertek__Account__c = accId.Id,
            buildertek__Project_Manager__c = UserInfo.getUserId(),
            Project_Tax_Rate__c = 10.5
        );
        if(Schema.sObjectType.buildertek__Project__c.isCreateable()&&
            Schema.sObjectType.buildertek__Project__c.fields.Name.isCreateable()&&
            Schema.sObjectType.buildertek__Project__c.fields.buildertek__Account__c.isCreateable() &&
			Schema.sObjectType.buildertek__Project__c.fields.buildertek__Opportunity__c.isCreateable() &&
			Schema.sObjectType.buildertek__Project__c.fields.buildertek__Project_Manager__c.isCreateable() &&
			Schema.sObjectType.buildertek__Project__c.fields.Project_Tax_Rate__c.isCreateable()){
            insert project;
		}
		return project;
    }
    
    public static buildertek__Purchase_Order__c createPO(Account accId, Contact contactId, buildertek__Project__c projId){
        List<buildertek__Purchase_Order__c> poList = new List<buildertek__Purchase_Order__c>();
           buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c(
            buildertek__Contractor_Resource__c = contactId.Id,
            buildertek__Vendor__c = accId.Id,
            buildertek__Project__c = projId.Id,
            buildertek__Ship_To_Address__c = accId.Id
        );
        poList.add(purchaseOrder);
        if(Schema.sObjectType.buildertek__Purchase_Order__c.isCreateable()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Contractor_Resource__c.isCreateable()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isCreateable() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isCreateable() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Ship_To_Address__c.isCreateable() ){
            insert poList;
		}
		system.debug('poList --------> '+poList[0]); 
		return poList[0];
           
    }
}