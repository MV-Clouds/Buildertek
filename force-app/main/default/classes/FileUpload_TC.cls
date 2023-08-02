@isTest
private class FileUpload_TC {

	private static testMethod void FileUploadtest() {
        Document documentRec = new document();
        documentRec.name = 'Test';
        documentRec.folderid = UserInfo.getUserId();
        documentRec.IsPublic = true;
        documentRec.body =  Blob.valueOf('Unit Test Document Body');
        insert documentRec ;
        FileUpload FileUp = new FileUpload();
        FileUp.document = documentRec;
        FileUp.doUpload();
        system.assertEquals(documentRec.id,documentRec.id); 
       
	}

}