@isTest
public class createDocumentController_TC {
    @isTest public static void testdocumentcontroller(){
        buildertek__MSA_Settings__c msasetting =new buildertek__MSA_Settings__c();
        msasetting.Name='MSA Settings';
        msasetting.buildertek__MSA_PDF_Template__c='buildertek__MSAFormPDF';
        msasetting.buildertek__MSA_Template__c='buildertek__MSASite';
        insert msasetting;
        createDocumentController crtrec=new createDocumentController();
        createDocumentController.innerclass createRec = new createDocumentController.innerclass();
        createRec.jname='test';
        createRec.jcitystate='test';
        createRec.jstate='test';
        createRec.jzip='test';
        createRec.jaddress='test';
        createRec.jsubDate='test';
        createRec.jphone='test';
        createRec.jfax='test';
        createRec.jcontractorlicence='test';
        createRec.jfederaltaxId='test';
        createRec.jsubBy='test';
        createRec.jsubprintedName='test';
        createRec.jsubVendorName='test';
        createRec.jcontractorby='test';
        createRec.jprintedName='test';
        createRec.jcontractorDate='test';
    }
}