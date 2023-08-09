public class BT_RFQConfiguration {
   // public Boolean isCreateChangeOrderonOverage{get;set;}
   // public buildertek__Admin_Interface_Node_Configuration__c adminterface {get;set;}
    public string  emailsubject {get;set;}
    public Boolean isUpdatethepricebook{get;set;}
    public Boolean isCreatePO{get;set;}
    public Boolean usingcommunities{get;set;}
    public Boolean isPrequalified{get;set;}
    public Boolean isCheckPortalUsers{get;set;}
    public Boolean isUsingProduct{get;set;}
    public String settingDescription{get;set;}

    public BT_RFQConfiguration(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id,buildertek__Update_Price_Book__c,   buildertek__Setting_Description__c,                  buildertek__Create_PO_On_Vendor_Acceptance__c,
                                                                                              buildertek__Using_Communities_for_RFQ__c,buildertek__Is_Pre_Qualified__c,
                                                                                              buildertek__Only_RFQ_Portal_Users__c,
                                                                                              buildertek__Change_Order_Configuration__c,buildertek__Email_Subject__c ,
                                                                                              buildertek__RFQLines_Using_Product__c
                                                                                            FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'RFQ Configuration'];
       // isCreateChangeOrderonOverage=adminInterfaceNodeConfigurations.buildertek__Change_Order_Configuration__c;
        emailsubject = adminInterfaceNodeConfigurations.buildertek__Email_Subject__c;
        isUpdatethepricebook = adminInterfaceNodeConfigurations.buildertek__Update_Price_Book__c;
        isCreatePO = adminInterfaceNodeConfigurations.buildertek__Create_PO_On_Vendor_Acceptance__c;
        usingcommunities = adminInterfaceNodeConfigurations.buildertek__Using_Communities_for_RFQ__c;
        isPrequalified = adminInterfaceNodeConfigurations.buildertek__Is_Pre_Qualified__c;
        isCheckPortalUsers = adminInterfaceNodeConfigurations.buildertek__Only_RFQ_Portal_Users__c;
        isUsingProduct = adminInterfaceNodeConfigurations.buildertek__RFQLines_Using_Product__c;
        settingDescription = adminInterfaceNodeConfigurations.buildertek__Setting_Description__c;

    }

    public void onCreateChangeOrderonOverage(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id,buildertek__Update_Price_Book__c,buildertek__Is_Pre_Qualified__c,buildertek__Only_RFQ_Portal_Users__c,
                                                                                              buildertek__Using_Communities_for_RFQ__c,buildertek__Create_PO_On_Vendor_Acceptance__c,buildertek__Change_Order_Configuration__c,buildertek__Email_Subject__c,
                                                                                              buildertek__RFQLines_Using_Product__c
                                                                                              FROM buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name=:'RFQ Configuration'];
        //adminInterfaceNodeConfigurations.buildertek__Change_Order_Configuration__c=isCreateChangeOrderonOverage;
        adminInterfaceNodeConfigurations.buildertek__Email_Subject__c = emailsubject;
        adminInterfaceNodeConfigurations.buildertek__Update_Price_Book__c = isUpdatethepricebook;
        adminInterfaceNodeConfigurations.buildertek__Create_PO_On_Vendor_Acceptance__c = isCreatePO;
        adminInterfaceNodeConfigurations.buildertek__Using_Communities_for_RFQ__c = usingcommunities;
        adminInterfaceNodeConfigurations.buildertek__Is_Pre_Qualified__c = isPrequalified;
        adminInterfaceNodeConfigurations.buildertek__Only_RFQ_Portal_Users__c = isCheckPortalUsers;
        adminInterfaceNodeConfigurations.buildertek__RFQLines_Using_Product__c = isUsingProduct;
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    }
}