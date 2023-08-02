public class PDFViewerController {
	@AuraEnabled
    public static string getFileData(String contentDocumentId){
    	ContentVersion cv = [SELECT Id, VersionData from ContentVersion where ContentDocumentId =: contentDocumentId];
        return EncodingUtil.base64Encode(cv.VersionData);
    }
}