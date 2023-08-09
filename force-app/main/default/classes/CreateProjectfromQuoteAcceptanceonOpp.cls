public class CreateProjectfromQuoteAcceptanceonOpp {

 public Boolean isCreateProjectfromQuoteAcceptanceonOpp{get;set;}
 public Boolean isCreatesendcustomerquoteaftersignature{get;set;}
 public Boolean isCreateProjectfromOpp{get;set;}
 public Boolean isUpdatetheOppAmount{get;set;}
 public Boolean isRemovesingleQuoteLineOption{get;set;}
 public Boolean hideGlobalMargin{get;set;}
 public Boolean hideGlobalMarkup{get;set;}
 public Boolean reject_Quote_on_Rejected_Lines{get;set;}
//  public Boolean Margin{get;set;}
//  public Boolean Markup{get;set;}

 public string  isBaseUrl {get;set;} 
 public buildertek__Admin_Interface_Node_Configuration__c admininterface {get;set;} 
 public string  emailsubject {get;set;} 
    
    public CreateProjectfromQuoteAcceptanceonOpp(){
        admininterface = New buildertek__Admin_Interface_Node_Configuration__c();
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Quote_Configuration__c,
                                                                                              buildertek__Email_Subject__c,buildertek__Send_customer_Quote_after_signature__c, buildertek__Reject_Quote_on_Rejected_Lines__c, 
                                                                                              buildertek__Create_Project_from_Opportunity__c,buildertek__Update_the_Opp_Amount__c,buildertek__Remove_Single_Quote_Line_Option__c,
                                                                                              buildertek__Default_Project_Owner__c,buildertek__Org_Base_URL__c, buildertek__Hide_Global_Margin__c, buildertek__Hide_Global_Markup__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Quote Configuration'];
        isCreateProjectfromQuoteAcceptanceonOpp=adminInterfaceNodeConfigurations.buildertek__Quote_Configuration__c;
        emailsubject = adminInterfaceNodeConfigurations.buildertek__Email_Subject__c;
        isCreatesendcustomerquoteaftersignature = adminInterfaceNodeConfigurations.buildertek__Send_customer_Quote_after_signature__c;
        isCreateProjectfromOpp = adminInterfaceNodeConfigurations.buildertek__Create_Project_from_Opportunity__c;
        isUpdatetheOppAmount = adminInterfaceNodeConfigurations.buildertek__Update_the_Opp_Amount__c;
        isRemovesingleQuoteLineOption = adminInterfaceNodeConfigurations.buildertek__Remove_Single_Quote_Line_Option__c;
        hideGlobalMargin = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Margin__c;
        hideGlobalMarkup = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Markup__c;
        admininterface.buildertek__Default_Project_Owner__c = adminInterfaceNodeConfigurations.buildertek__Default_Project_Owner__c;
        reject_Quote_on_Rejected_Lines = adminInterfaceNodeConfigurations.buildertek__Reject_Quote_on_Rejected_Lines__c;
        //if(adminInterfaceNodeConfigurations.buildertek__Org_Base_URL__c == null){
            isBaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
       // }else{
        //    isBaseUrl = adminInterfaceNodeConfigurations.buildertek__Org_Base_URL__c;
       // }
        
        
    }
    
    public void onCreateProjectfromQuoteAcceptanceonOpp(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Quote_Configuration__c,buildertek__Org_Base_URL__c,buildertek__Email_Subject__c,buildertek__Send_customer_Quote_after_signature__c,buildertek__Create_Project_from_Opportunity__c,buildertek__Remove_Single_Quote_Line_Option__c,buildertek__Default_Project_Owner__c, buildertek__Reject_Quote_on_Rejected_Lines__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Quote Configuration'];
        adminInterfaceNodeConfigurations.buildertek__Quote_Configuration__c=isCreateProjectfromQuoteAcceptanceonOpp;
        adminInterfaceNodeConfigurations.buildertek__Email_Subject__c = emailsubject;
        adminInterfaceNodeConfigurations.buildertek__Send_customer_Quote_after_signature__c = isCreatesendcustomerquoteaftersignature;
        adminInterfaceNodeConfigurations.buildertek__Create_Project_from_Opportunity__c=isCreateProjectfromOpp;
        adminInterfaceNodeConfigurations.buildertek__Update_the_Opp_Amount__c=isUpdatetheOppAmount;
        adminInterfaceNodeConfigurations.buildertek__Default_Project_Owner__c = admininterface.buildertek__Default_Project_Owner__c;
        adminInterfaceNodeConfigurations.buildertek__Remove_Single_Quote_Line_Option__c = isRemovesingleQuoteLineOption;
        adminInterfaceNodeConfigurations.buildertek__Hide_Global_Margin__c = hideGlobalMargin;
        adminInterfaceNodeConfigurations.buildertek__Hide_Global_Markup__c = hideGlobalMarkup;
        adminInterfaceNodeConfigurations.buildertek__Reject_Quote_on_Rejected_Lines__c = reject_Quote_on_Rejected_Lines;



        system.debug('isBaseUrl'+isBaseUrl);
        System.debug(adminInterfaceNodeConfigurations.buildertek__Remove_Single_Quote_Line_Option__c);
        admininterface.buildertek__Org_Base_URL__c = isBaseUrl;
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    }
}