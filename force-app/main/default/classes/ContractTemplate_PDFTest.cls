@isTest
private class ContractTemplate_PDFTest {

	private static testMethod void test() {
	    RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Contract'];
        buildertek__Template_Header__c th = new buildertek__Template_Header__c();
        th.buildertek__Description__c = 'test';
        th.buildertek__Template_Header__c = 'test';
        insert th;
        System.assert(th.Id!=null);
        
        buildertek__Template_Footer__c tf = new buildertek__Template_Footer__c();
        tf.buildertek__Description__c = 'test';
        tf.buildertek__Template_Footer__c = 'test';
        insert tf;
        System.assert(tf.Id!=null);
        
        buildertek__Quote_Template__c qt = new buildertek__Quote_Template__c();
        qt.buildertek__Template_Body__c = 'Test';
        qt.buildertek__Template_Format__c = 'Contract';
        qt.RecordTypeId = rt.Id;
        qt.buildertek__Template_Header__c = th.id;
        qt.buildertek__Template_Footer__c = tf.Id;
        insert qt;
        System.assert(qt.Id!=null);
	    
        DocTemplate_Page__c dtp = new DocTemplate_Page__c();
        dtp.Doc_Template__c=qt.Id;
        insert dtp;
        System.assert(dtp.Id!=null);
        
        
	    buildertek__Contract__c contractToInsert = new buildertek__Contract__c();
	    contractToInsert.Name = 'Test Contract';
	    contractToInsert.Doc_Template__c = qt.Id;
	    insert contractToInsert;
        System.assert(contractToInsert.Id!=null);
            
        Quote_Lineitem_Fields__c qlif = new Quote_Lineitem_Fields__c();
        qlif.Quote_Template__c=qt.Id;
        qlif.DocTemplate_Page__c=dtp.Id;
        qlif.Field_API_Name__c='id';
        insert qlif;
        System.assert(qlif.Id!=null);
        
	    ApexPages.currentPage().getParameters().put('qtid', contractToInsert.Doc_Template__c);
	    ApexPages.currentPage().getParameters().put('qid', contractToInsert.Id);
	    
	    ContractTemplate_PDF_AC CT = new ContractTemplate_PDF_AC();
        CT.myText='TEST';
        CT.mss='TEST';
        CT.LineItemsSortOrder=8.9;
        ContractTemplate_PDF_AC.innerClass innerclassRec= new ContractTemplate_PDF_AC.innerClass('test',dtp);
	    
	}

}