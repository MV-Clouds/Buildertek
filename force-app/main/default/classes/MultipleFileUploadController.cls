public with sharing class MultipleFileUploadController{
	// @AuraEnabled
	// public static List<ContentDocument> getAllFilesOnsObjectRecord(Id sObjectId){
	// 	List<ContentDocument> contentDocumentListToReturn = new List<ContentDocument>();
	// 	List<ContentDocumentLink> contentDocLinkOnsObjectList = new List<ContentDocumentLink>();

	// 	contentDocLinkOnsObjectList = [Select id, ContentDocumentId, LinkedEntityId
	// 	                               From ContentDocumentLink
	// 	                               Where LinkedEntityId = :sObjectId];
	// 	Set<Id> contentDocIdSet = new Set<Id>();

	// 	if (contentDocLinkOnsObjectList != null && !contentDocLinkOnsObjectList.isEmpty()){
	// 		for (ContentDocumentLink conDocLink : contentDocLinkOnsObjectList){
	// 			contentDocIdSet.add(conDocLink.ContentDocumentId);
	// 		}
	// 	}

	// 	if (contentDocIdSet != null && !contentDocIdSet.isEmpty()){
	// 		contentDocumentListToReturn = [Select Id, Title
	// 		                               From ContentDocument
	// 		                               Where ID IN :contentDocIdSet];
	// 	}

	// 	if (contentDocumentListToReturn != null && !contentDocumentListToReturn.isEmpty()){
	// 		return contentDocumentListToReturn;
	// 	} else{
	// 		return null;
	// 	}
	// }

	@AuraEnabled
	public static void deleteFiles(String filesIdArrStr){
		List<ContentDocument> contentDocumentToDelete = new List<ContentDocument>();
		Set<Id> filesIdSet = new Set<Id>();
		if (filesIdArrStr != null && filesIdArrStr != ''){
			filesIdSet = (Set<Id>)JSON.deserialize(filesIdArrStr, Set<Id>.class);
		}

		if (filesIdSet != null && !filesIdSet.isEmpty()){
			contentDocumentToDelete = [Select id
			                           From ContentDocument
			                           Where Id IN :filesIdSet];
			if (contentDocumentToDelete != null && !contentDocumentToDelete.isEmpty()){
				try{
					delete contentDocumentToDelete;
				} catch (Exception e){
					System.debug('Exception--' + e.getMessage());
					throw new AuraHandledException(e.getMessage());
				}
			}
		}
	}
}