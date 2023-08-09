@isTest
public class PreQualificationTemplatesController_TC {
    @isTest 
    public static void testtemplatecontroller(){
      buildertek__Admin_Interface_Node_Configuration__c admininterface=new buildertek__Admin_Interface_Node_Configuration__c();
        admininterface.Name='Pre Qualification Configuration';
        admininterface.buildertek__Selected_Templates__c='Pre_QualProcess_VF';
        insert admininterface;
        
        PreQualificationTemplatesController.getTemplates();
        PreQualificationTemplatesController.saveNode('test');
        PreQualificationTemplatesController.getSelectedTemplates();
        
        
    }
}