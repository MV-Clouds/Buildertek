public with sharing class ImageAttachmentController{
	public string quoteId{ get; set; }

	public List<Attachment> att{ get; set; }

	public String blobBody{ get; set; }

	public ImageAttachmentController(){
		att = [Select Id, Name, Body, ParentId
		       FROM Attachment
		       WHERE ContentType = :'image/jpeg'];
		Blob csvBlob = att[0].Body;
		blobBody = EncodingUtil.base64Encode(csvBlob);
	}
}