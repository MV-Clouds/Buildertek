public class BT_ImportPurchaseOrder {
    
    /* for import data into sobject and insert data from csv file  */ 
    @AuraEnabled
    public static string insertData(String strfromle){
        String returnresponse ='';
        List<buildertek__Purchase_Order__c> PurchaseOrderListtoInsert = new List<buildertek__Purchase_Order__c>();
        List<buildertek__Purchase_Order_Item__c> PurchaseOrderItemListtoInsert = new List<buildertek__Purchase_Order_Item__c>();
        //system.debug('strfromle = ' + strfromle);
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);
        system.debug('datalist = ' + datalist);
        system.debug('datalistSize = ' + datalist.size());
        map<String,String> insertedPOs = new map<String,String>();
        
        //For Vendors
        list<String> vendorNames = new List<String>();
        for(fieldWrapper wrapper: datalist){
            if(wrapper.Vendor != null && wrapper.Vendor != ''){
                vendorNames.add(wrapper.Vendor);
            }
        }
        list<Account> vendor1 = new list<Account>();
        vendor1 = [select Id, Name from Account where Name IN: vendorNames];
        map<String, Account> vendormap = new map<String,Account>();
        for(Account vendorItem : vendor1){
            vendormap.put(vendorItem.Name,vendorItem); 
        }
        
        // For Projects
        list<String> projectNames = new List<String>();
        
        for(fieldWrapper wrapper: datalist){
            if(wrapper.Project != null && wrapper.Project != ''){
                projectNames.add(wrapper.Project);
            }
        }
        list<buildertek__Project__c> project1 = new list<buildertek__Project__c>();
        project1 = [select Id, Name from buildertek__Project__c where Name IN: projectNames];
        map<String, buildertek__Project__c> projectmap = new map<String,buildertek__Project__c>();
        for(buildertek__Project__c projectItem : project1){
            projectmap.put(projectItem.Name,projectItem); 
        }
        
        //For Products
        list<String> productNames = new List<String>();
        for(fieldWrapper wrapper: datalist){
            if(wrapper.Product != null && wrapper.Product != ''){
                productNames.add(wrapper.Product);
            }
        }
        list<buildertek__Product__c	> product1 = new list<buildertek__Product__c	>();
        product1 = [select Id, Name from buildertek__Product__c	 where Name IN: productNames];
        map<String, buildertek__Product__c	> productMap = new map<String,buildertek__Product__c	>();
        for(buildertek__Product__c	 productItem : product1){
            productMap.put(productItem.Name,productItem); 
        }
        
        //Inserting purchase Order
        
        Map<String,buildertek__Purchase_Order__c> newPOMap = new Map<String,buildertek__Purchase_Order__c>();
        map<String,String> UniquePO = new map<String,String>();
        for(fieldWrapper wrapper: datalist){
            String PoFiledsString = '';
            buildertek__Purchase_Order__c PO =new  buildertek__Purchase_Order__c();
            PO.buildertek__Description__c = wrapper.Description;
            PoFiledsString = wrapper.Description;
           
            if(projectmap.keySet().contains(wrapper.Project) && wrapper.Project != null && wrapper.Project != ''){
                PO.buildertek__Project__c = projectmap.get(wrapper.Project).Id;
                PoFiledsString += '@#$'+projectmap.get(wrapper.Project).Id;
            }
            PO.buildertek__Required_Delivery_Date__c = wrapper.RequiredDeliveryDate;
            PoFiledsString +=  '@#$'+wrapper.RequiredDeliveryDate;
            PO.buildertek__Status__c = wrapper.Status;
            PoFiledsString += '@#$'+wrapper.Status;
            if(vendormap.keySet().contains(wrapper.Vendor) && wrapper.Vendor != null && wrapper.Vendor != ''){
                PO.buildertek__Vendor__c = vendormap.get(wrapper.Vendor).Id;
                PoFiledsString += '@#$'+vendormap.get(wrapper.Vendor).Id;
            }

            if (!UniquePO.containsKey(PoFiledsString)) {
                UniquePO.put(PoFiledsString,PoFiledsString);
                PurchaseOrderListtoInsert.add(PO); 
            }                 
        }
              
        if(PurchaseOrderListtoInsert.size() > 0){
            try {
                insert PurchaseOrderListtoInsert;
                for(buildertek__Purchase_Order__c PO: PurchaseOrderListtoInsert){
                    String PoFiledsString1 = '';
                    PoFiledsString1 = PO.buildertek__Description__c;
                    PoFiledsString1 += '@#$'+PO.buildertek__Project__c;
                    PoFiledsString1 +=  '@#$'+PO.buildertek__Required_Delivery_Date__c;
                    PoFiledsString1 += '@#$'+PO.buildertek__Status__c;
                    PoFiledsString1 += '@#$'+PO.buildertek__Vendor__c;
                    if (!insertedPOs.containsKey(PoFiledsString1)) {
                        insertedPOs.put(PoFiledsString1,PO.Id);
                    }  
                    newPOMap.put(PO.Id, PO);
                }
                returnresponse = 'SUCCESS';
            }
            catch(Exception ex){
                returnresponse = 'ERROR';
            }
        }
        
        // Creating purchase order lines
        //  for(String POItemId : insertedPOs.keySet()){
        map<String,String> poLinesMap = new map<String,String>();
        for(fieldWrapper POLwrapper: datalist){
            buildertek__Purchase_Order_Item__c POL =new  buildertek__Purchase_Order_Item__c();
            String PoFiledsString = '';
            PoFiledsString = POLwrapper.Description;
            PoFiledsString += '@#$'+projectmap.get(POLwrapper.Project).Id;
            PoFiledsString += '@#$'+POLwrapper.RequiredDeliveryDate;
            PoFiledsString += '@#$'+POLwrapper.Status;
            PoFiledsString += '@#$'+vendormap.get(POLwrapper.Vendor).Id;
            system.debug(PoFiledsString);
            if(insertedPOs.containsKey(PoFiledsString)){
                
                POL.buildertek__Purchase_Order__c = insertedPOs.get(PoFiledsString);
            }
            POL.buildertek__Quantity__c = POLwrapper.Quantity;
            POL.buildertek__Description__c = POLwrapper.PODescription;
            POL.buildertek__Discount__c = POLwrapper.Discount;
            if(productMap.keySet().contains(POLwrapper.Product) && POLwrapper.Product != null && POLwrapper.Product != ''){
                POL.buildertek__Product__c = productMap.get(POLwrapper.Product).Id;
            }
             system.debug(String.valueOf(POLwrapper.Received) == null);
            system.debug(String.valueOf(POLwrapper.Received) == 'null');
            if(String.valueOf(POLwrapper.Received) != null && String.valueOf(POLwrapper.Received) != ''){
                POL.buildertek__Received__c = POLwrapper.Received;
            }
            POL.buildertek__Unit_Price__c = POLwrapper.UnitCost;
            POL.buildertek__UOM__c = POLwrapper.UOM;
            PurchaseOrderItemListtoInsert.add(POL);            
        }
        //  }
        if(PurchaseOrderItemListtoInsert.size() > 0){
            try {
                insert PurchaseOrderItemListtoInsert;
                returnresponse = 'SUCCESS';
            }
            catch(Exception ex){
                system.debug(ex);
                returnresponse = 'ERROR';
            }
        }
        
        return returnresponse;
    }
    
    public class fieldWrapper{
        // purchase order fields
        public String Description;
        public String Project;
        public Date RequiredDeliveryDate;
        public String Vendor;
        public String Status;
        
        public String PODescription;
        public Decimal Discount;
        public String Product;
        public String PurchaseOrder;
        public Decimal Quantity;
        public Decimal Received;
        public Decimal UnitCost;
        public String UOM;
    } 
}