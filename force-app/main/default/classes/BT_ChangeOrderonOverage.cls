public class BT_ChangeOrderonOverage {
    public Boolean isCreateChangeOrderonOverage{get;set;}
    public buildertek__Admin_Interface_Node_Configuration__c adminterface {get;set;} 
    public string  emailsubject {get;set;}
    public string  createCO {get;set;}

    // public Boolean  CheckRecordTypeVisibilityYes {get;set;}
    // public Boolean  CheckRecordTypeVisibilityNo {get;set;}
    // public Boolean  CheckVisibility {get;set;}
    public Boolean  radiovalue {get;set;}
    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('true','Yes')); 
        options.add(new SelectOption('false','No')); 
        return options; 
    }
    
    public BT_ChangeOrderonOverage(){
        
        List<BT_CO_Lines_From_Product__c> test = [SELECT buildertek__CO_Lines_Using_Product__c from BT_CO_Lines_From_Product__c];
        if(test.size() > 0) radiovalue = test[0].buildertek__CO_Lines_Using_Product__c;


        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Change_Order_Configuration__c,buildertek__Email_Subject__c , buildertek__Create_Change_order__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Change Order Configuration'];
        isCreateChangeOrderonOverage=adminInterfaceNodeConfigurations.buildertek__Change_Order_Configuration__c;
        emailsubject = adminInterfaceNodeConfigurations.buildertek__Email_Subject__c;
        createCO=adminInterfaceNodeConfigurations.buildertek__Create_Change_order__c;
    
    }
    


    public void onCreateChangeOrderonOverage(){
        System.debug('radiovalue=='+radiovalue);
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Change_Order_Configuration__c,buildertek__Email_Subject__c , buildertek__Create_Change_order__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Change Order Configuration'];
        adminInterfaceNodeConfigurations.buildertek__Change_Order_Configuration__c=isCreateChangeOrderonOverage;
        adminInterfaceNodeConfigurations.buildertek__Email_Subject__c = emailsubject;
        adminInterfaceNodeConfigurations.buildertek__Create_Change_order__c = createCO;

        update adminInterfaceNodeConfigurations;

        List<BT_CO_Lines_From_Product__c> test = [SELECT buildertek__CO_Lines_Using_Product__c from BT_CO_Lines_From_Product__c];
       
        if(test.size() > 0) test[0].buildertek__CO_Lines_Using_Product__c = radiovalue;
        System.debug('Data to be updated==='+test);
        update test;

        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    }


}