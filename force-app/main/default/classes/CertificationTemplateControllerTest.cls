@isTest
public class CertificationTemplateControllerTest {
    static testMethod void test() {    
        buildertek__Course__c Course = new buildertek__Course__c();
        Course.Name = 'Test Cousrse';
        Course.buildertek__Certification_Template__c = 'TempNAME';
        insert Course;
        CertificationTemplateController.updateCourse(Course.id,'TesTTemp');  
    }

}