public class CreateFileController {
    public void init(String base64String){
        List<FilesWrapper> filesList = (List<FilesWrapper>)System.JSON.deserialize(base64String, List<FilesWrapper>.class);
        system.debug('filesList ------> '+filesList);       
    }
    
    public class FilesWrapper{
        @AuraEnabled public String fileName;
        @AuraEnabled public String fileContent;
        @AuraEnabled public String parentId;
    }
    
}