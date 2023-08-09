public with sharing class AddProductController{
    public Id serviceId{get;set;}
    public Id requestId{get;set;}
    public boolean blnDisplayMessage{get;set;}
    public boolean blnHasEditAccess{get;set;}
    public List<wrapsObjectList> lstProduct{get;set;}
    public Service_Request__c objService{get;set;}
    
    public AddProductController(){
        requestId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        serviceId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        objService = new Service_Request__c();
        if(serviceId != null && Schema.sObjectType.Service_Request__c.fields.Id.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.Name.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.Request_Status__c.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.Preferred_Date_of_Service__c.isAccessible()
            && Schema.sObjectType.Contact.fields.Name.isAccessible()){
            objService = [Select Id,Name,Customer_Name__r.Name,Request_Status__c,Preferred_Date_of_Service__c From Service_Request__c Where Id =: serviceId];
        }
        blnDisplayMessage = false;
        blnHasEditAccess = true;
        lstProduct = new List<wrapsObjectList>();
        wrapsObjectList objWrapper = new wrapsObjectList();
        objWrapper.counter = 1;
        lstProduct.add(objWrapper);
        loadProductsByFamily();
    }
    
    public void getisRecordAccessible(){
         requestId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        if(requestId == null){
            blnDisplayMessage = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO,'URL does not exist.'));
        }
        else{
             List<UserRecordAccess> lstUserRecord;
            if (Schema.sObjectType.UserRecordAccess.fields.RecordId.isAccessible() 
                && Schema.sObjectType.UserRecordAccess.fields.HasEditAccess.isAccessible() ){
                    
               lstUserRecord = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =: requestId];
                if(lstUserRecord.size() > 0)
                    blnHasEditAccess = lstUserRecord[0].HasEditAccess;
                if(blnHasEditAccess == false){
                    blnDisplayMessage = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO,'User does not have an access to this page.'));
                } 
                
            }
            
        }
    }
    
    public PageReference cancelAction() {
        pageReference pref = new pageReference('/' + ApexPages.currentPage().getParameters().get('id'));
        pref.setRedirect(true);
        return pref;
    }
    
    public void loadProductsByFamily(){     
        string strIndex = Apexpages.currentPage().getParameters().get('index');
        integer index = 0;
        if(strIndex != null)
            index = integer.valueOf(strIndex);
        wrapsObjectList objWrapper = lstProduct[index];
        List<SelectOption> lstProductNames = new List<SelectOption>();
        if (Schema.sObjectType.Product2.fields.Name.isAccessible() && 
             Schema.sObjectType.Inventory_Management__c.fields.Id.isAccessible() &&
             Schema.sObjectType.Inventory_Management__c.fields.Product_Name__c.isAccessible() && 
             Schema.sObjectType.Inventory_Management__c.fields.Product_Family__c.isAccessible()) {
            List<Inventory_Management__c> lstProducts = [Select Id,Product_Name__r.Name From Inventory_Management__c Where Product_Family__c =: objWrapper.strProductFamily];
            lstProductNames.add(new SelectOption('','--None--'));
            for(Inventory_Management__c objProduct : lstProducts){
                lstProductNames.add(new SelectOption(objProduct.Id,objProduct.Product_Name__r.Name));
            }
            objWrapper.lstProductNames = lstProductNames;
            objWrapper.objProduct = null;
        }
    }
    
    public void loadInventoryDetailsByProduct(){
        string strIndex = Apexpages.currentPage().getParameters().get('index');
        integer index = 0;
        if(strIndex != null)
            index = integer.valueOf(strIndex);
        wrapsObjectList objWrapper = lstProduct[index];
        Id productId = (Id)objWrapper.strProductId;
       list<Inventory_Management__c> invmangment;
        if(Schema.sObjectType.Inventory_Management__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Inventory_Management__c.fields.Current_Stock__c.isAccessible() &&
            Schema.sObjectType.Inventory_Management__c.fields.Unit__c.isAccessible() &&
            Schema.sObjectType.Inventory_Management__c.fields.Cost_Per_Unit__c.isAccessible() &&
            Schema.sObjectType.Inventory_Management__c.fields.Product_Name__c.isAccessible() &&
            Schema.sObjectType.Inventory_Management__c.fields.Product_Description__c.isAccessible() &&
             Schema.sObjectType.Product__c.fields.Name.isAccessible() ){
           invmangment = [Select Id,Current_Stock__c,Unit__c,Cost_Per_Unit__c,Product_Name__c,Product_Name__r.Name,Product_Description__c From Inventory_Management__c Where Id = : productId];
             }
        Map<Id,Inventory_Management__c> mapProduct = new Map<Id,Inventory_Management__c>(invmangment);
        objWrapper.objProduct = mapProduct.get(productId);
    }
    
    public void addRow(){
        String strIndex = Apexpages.currentPage().getParameters().get('index');
        wrapsObjectList objWrapper = new wrapsObjectList();
        objWrapper.counter = integer.valueOf(strIndex) + 1;
        lstProduct.add(objWrapper);
    }
    
    public void removeRow(){
        String strIndex = Apexpages.currentPage().getParameters().get('index');
        integer index = 0;
        if(strIndex != null)
            index = integer.valueOf(strIndex);
        lstProduct.remove(index);
        integer i = 1;
        for(wrapsObjectList objWrapper : lstProduct){
            objWrapper.counter = i;
            i++;
        }
    }
    
    public PageReference saveAction(){
        //serviceId = ApexPages.currentPage().getParameters().get('id');
        
        Map<Id,Product__c> mapOfProducts = new Map<Id,Product__c>();
        List<Product__c> productsList;
        if( Schema.sObjectType.Product__c.fields.Id.isAccessible()
            && Schema.sObjectType.Product__c.fields.Product__c.isAccessible()
            && Schema.sObjectType.Product__c.fields.Cost__c.isAccessible()
            && Schema.sObjectType.Product__c.fields.Quantity__c.isAccessible()){
            productsList = [Select Id,Product__c,Cost__c,Quantity__c From Product__c Where Service_Request__c = : serviceId];    
        }
        
        for(Product__c objP : productsList){
            mapOfProducts.put(objP.Product__c,objP);
        }
        
        List<Product__c> lstProductsTOInsert = new List<Product__c>();
        Map<Id,Integer> mapOfProductQuantity = new Map<Id,Integer>();
        System.debug('lst'+ lstProduct);
        for(wrapsObjectList objWrapper : lstProduct){
            string strProdId = objWrapper.strProductId;
            if(strProdId != null){
               if(!mapOfProductQuantity.containsKey((Id)strProdId)){
                    mapOfProductQuantity.put((Id)strProdId,objWrapper.intQuantity);
                }
                else{
                    mapOfProductQuantity.put((Id)strProdId,mapOfProductQuantity.get((Id)strProdId) + objWrapper.intQuantity);
                }
            }
        }
        system.debug('mapOfProductQuantity :: ' + mapOfProductQuantity);
        Set<Id> setofProdIds = new Set<Id>();
        Product__c objProduct = new Product__c();
        for(wrapsObjectList objWrapper : lstProduct){
            if(!setofProdIds.contains(objWrapper.strProductId)){
                setofProdIds.add(objWrapper.strProductId);
                system.debug('mapofproducts'+mapOfProducts);
                system.debug('objWrapper'+objWrapper);
                System.debug('map'+mapOfProducts.containsKey(objWrapper.objProduct.Id));
                if(mapOfProducts.containsKey(objWrapper.objProduct.Id)){
                    if(Schema.sObjectType.Product__c.fields.Product_Name__c.isCreateable() 
                        && Schema.sObjectType.Product__c.fields.Quantity__c.isCreateable()
                        && Schema.sObjectType.Product__c.fields.Additional_Information__c.isCreateable() 
                        && Schema.sObjectType.Product__c.fields.Cost__c.isCreateable()
                        && Schema.sObjectType.Product__c.fields.Product_Name__c.isUpdateable() 
                        && Schema.sObjectType.Product__c.fields.Quantity__c.isUpdateable()
                        && Schema.sObjectType.Product__c.fields.Additional_Information__c.isUpdateable() 
                        && Schema.sObjectType.Product__c.fields.Cost__c.isUpdateable()){
                    objProduct = mapOfProducts.get(objWrapper.objProduct.Id);
                   
                    objProduct.Product_Name__c = objWrapper.objProduct.Product_Name__r.Name;
                    objProduct.Quantity__c = objProduct.Quantity__c + mapOfProductQuantity.get((Id)objWrapper.strProductId);
                    objProduct.Additional_Information__c = objWrapper.strDescription;
                    objProduct.Cost__c = objProduct.Cost__c + (objWrapper.objProduct.Cost_Per_Unit__c == null ? 0 : objWrapper.objProduct.Cost_Per_Unit__c) * mapOfProductQuantity.get((Id)objWrapper.strProductId);
                    }
                        
                }
                else{
                    objProduct = new Product__c();
                    if(Schema.sObjectType.Product__c.fields.Product_Name__c.isCreateable()
                        && Schema.sObjectType.Product__c.fields.Product__c.isCreateable()
                        && Schema.sObjectType.Product__c.fields.Service_Request__c.isCreateable()
                        && Schema.sObjectType.Product__c.fields.Quantity__c.isCreateable()
                        && Schema.sObjectType.Product__c.fields.Additional_Information__c.isCreateable()
                        && Schema.sObjectType.Product__c.fields.Cost__c.isCreateable() 
                        && Schema.sObjectType.Product__c.fields.Product_Name__c.isUpdateable() 
                        && Schema.sObjectType.Product__c.fields.Quantity__c.isUpdateable() 
                        && Schema.sObjectType.Product__c.fields.Additional_Information__c.isUpdateable()
                        && Schema.sObjectType.Product__c.fields.Cost__c.isUpdateable()
                        && Schema.sObjectType.Product__c.fields.Product__c.isUpdateable()
                        && Schema.sObjectType.Product__c.fields.Service_Request__c.isUpdateable()){
                    objProduct.Product__c = objWrapper.objProduct.Id;
                    objProduct.Product_Name__c = objWrapper.objProduct.Product_Name__r.Name;
                    objProduct.Service_Request__c = (Id)serviceId;
                    objProduct.Quantity__c = mapOfProductQuantity.get((Id)objWrapper.strProductId);
                    objProduct.Additional_Information__c = objWrapper.strDescription;
                    objProduct.Cost__c = (objWrapper.objProduct.Cost_Per_Unit__c == null ? 0 : objWrapper.objProduct.Cost_Per_Unit__c) * mapOfProductQuantity.get((Id)objWrapper.strProductId);
                    }
                }
                lstProductsTOInsert.add(objProduct);
            }
        }
        try{
            if(lstProductsTOInsert.size() > 0){
                upsert lstProductsTOInsert;
                pageReference pref = new pageReference('/' + serviceId);
                pref.setRedirect(true);
                return pref;
            }
            return null;
        }
        catch(Exception ex){
            blnDisplayMessage = true;
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,ex.getMessage()));
            return null;
        }
    }
    
    public static List<SelectOption> getProductFamily(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--None--'));
        //integer intI = 1;
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getValue(),f.getLabel()));
            //intI++;
        }
        return options;
    }
    public class wrapsObjectList{
        public Integer counter { get; set; }
        public Inventory_Management__c objProduct{get;set;}
        public string strProductFamily{get;set;}
        public List<SelectOption> lstProductFamily{get;set;}
        public string strProductId{get;set;}
        public List<SelectOption> lstProductNames{get;set;}
        public integer intQuantity{get;set;}
        public string strDescription{get;set;}
        public wrapsObjectList(){
            lstProductFamily = AddProductController.getProductFamily();
            intQuantity = 1;
        }
    }
}