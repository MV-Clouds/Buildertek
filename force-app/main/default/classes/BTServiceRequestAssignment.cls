/* **************************************************************************
* Copyright 2017-2018, thoriyas tech.
* All rights reserved
*
* Controller Class: BTServiceRequestAssignment
* Created by Sagar Thoriya: 02/09/2017
*
* Modifications:
* - Sagar Thoriya, 02/09/2017 - Initial Development
************************************************************************** */

public with sharing class BTServiceRequestAssignment {
	
	
	/**************************************************************************
       Purpose: to get the all service request detail
       Parameters: NA
       Returns: service request list 
       Throws [Exceptions]: NA
    ****************************************************************************/
    @AuraEnabled
    public static List<Service_Request__c> getAllSR(){
        List<Service_Request__c> srList;
        if(Schema.sObjectType.Service_Request__c.fields.Id.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.Name.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.Request_Status__c.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.Customer_Name__c.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.subject__c.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.Customer_Email__c.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.createdDate.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.Customer_Address__c.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.Customer_Phone__c.isAccessible()
            && Schema.sObjectType.Service_Request__c.fields.buildertek__Primary_Assignee__c.isAccessible()
            && Schema.sObjectType.User.fields.Name.isAccessible()
            && Schema.sObjectType.Contact.fields.Name.isAccessible()
            && Schema.sObjectType.Contact.fields.MailingLatitude.isAccessible()
            && Schema.sObjectType.Contact.fields.MailingLongitude.isAccessible()){
            
            srList = [Select Id, 
                            Name,
                            Request_Status__c,
                            Customer_Name__c, 
                            subject__c, 
                            createdDate, 
                            CreatedByID,
                            Customer_Name__r.Name,
                            Customer_Email__c,
                            Customer_Address__c, 
                            Customer_Phone__c, 
                            buildertek__Primary_Assignee__c,
                            Customer_Name__r.MailingLatitude, 
                            Customer_Name__r.MailingLongitude 
                            from Service_Request__c 
                            where Request_Status__c != 'Complete' 
                            And  Customer_Name__r.MailingLatitude != null];    
        }                                          
        return srList;
    }
    
    /**************************************************************************
       Purpose: to get the all Available Resources
       Parameters: NA
       Returns: Resource list 
       Throws [Exceptions]: NA
    ****************************************************************************/
    @AuraEnabled
    public static List<user> getAllAvailableResources(){
        List<User> userList;
        if(Schema.sObjectType.User.fields.id.isAccessible()
            && Schema.sObjectType.User.fields.name.isAccessible()
            && Schema.sObjectType.User.fields.title.isAccessible()){
            userList = [select id, name, title from User where profile.name = 'BT Service 360 Employee'];    
        }
        return userList;
    }
    
    /**************************************************************************
       Purpose: Assigned aservice requiest to resource
       Parameters: NA
       Returns: if any error
       Throws [Exceptions]: NA
    ****************************************************************************/
    @AuraEnabled
    public static string assignedResources(string srId, string resourceId){
        try{
            Service_Request_Assignee__c objServiceRequestAssignee = new Service_Request_Assignee__c();
            if (Schema.sObjectType.Service_Request_Assignee__c.fields.Employee__c.isCreateable()
                && Schema.sObjectType.Service_Request_Assignee__c.fields.Primary__c.isCreateable()
                && Schema.sObjectType.Service_Request_Assignee__c.fields.Service_Request__c.isCreateable()) {
                
                objServiceRequestAssignee.Employee__c = resourceId;
	            objServiceRequestAssignee.Primary__c = true;
	            objServiceRequestAssignee.Service_Request__c = srId;
                    
            }
	        insert objServiceRequestAssignee;
	        
	        return 'Service request Assigned sucussyfull';
        }catch(Exception ex){
        	return ex.getMessage();
        }
        return null;
    }
    
    /**************************************************************************
       Purpose: to get the list view id
       Parameters: NA
       Returns:list view
       Throws [Exceptions]: NA
    ****************************************************************************/
     @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews;
        if(Schema.sObjectType.ListView.fields.id.isAccessible()
            && Schema.sObjectType.ListView.fields.Name.isAccessible()){
            
            listviews =  [SELECT Id, Name FROM ListView WHERE SobjectType = 'Service_Request__c' AND NAME = 'All'];    
        }
        // Perform isAccessible() check here
        return listviews;
    }
    
    
     /**************************************************************************
       Purpose: to get the product list
       Parameters: NA
       Returns:product list
       Throws [Exceptions]: NA
    ****************************************************************************/
     @AuraEnabled
    public static List<productList> getProductList() {
        List<productList> lstProducts = new List<productList>();
        productList obj = new productList();
        obj.products = [Select Id, Name from product2 ];
        lstProducts.add(obj);
        
        obj = new productList();
        obj.products = [Select Id, Name from product2];
        lstProducts.add(obj);
        
        obj = new productList();
        obj.products = [Select Id, Name from product2];
        lstProducts.add(obj);
        
        obj = new productList();
        obj.products = [Select Id, Name from product2];
        lstProducts.add(obj);
        
        obj = new productList();
        obj.products = [Select Id, Name from product2];
        lstProducts.add(obj);
        
        return lstProducts;
    }
    
    /**************************************************************************
       Purpose: to get the product list
       Parameters: NA
       Returns:product list
       Throws [Exceptions]: NA
    ****************************************************************************/
     @AuraEnabled
    public static productList addNewProduct() {
        List<productList> lstProducts = new List<productList>();
        productList obj = new productList();
        obj.products = [Select Id, Name from product2];
        return obj;
    }
    
    /**************************************************************************
       Purpose: to get the product family list
       Parameters: NA
       Returns:product family list
       Throws [Exceptions]: NA
    ****************************************************************************/
    @AuraEnabled
    public static List<String> getProductFamily(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple){
            options.add(f.getLabel());
        }
        options.add('--None--');
        return options;
    }
    
    /**************************************************************************
       Purpose: productList calss to build product list
       Parameters: NA
       Returns: 
       Throws [Exceptions]: NA
    ****************************************************************************/
    
    public class productList{
    	
    	@AuraEnabled
    	public List<product2> products {get;set;}
    	
    	@AuraEnabled
    	public Product__c objProduct {get;set;}
    }
}