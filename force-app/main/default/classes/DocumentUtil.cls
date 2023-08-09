public with sharing class DocumentUtil {
  public static DocumentUtil instance = null;
  public Id orgID{get; set;}
  public Document doc;
  public static Document doc = null; 
  
  public DocumentUtil() {
      Organization org;
      if(Schema.sObjectType.Organization.fields.id.isAccessible()){
        org =  [SELECT Id FROM Organization limit 1];   
      }
        orgID = org.Id;
  }
  
  
  public String getURL() {
    return getURL(doc);
  }
  
  public String getURL(Document d) {
    // Rewrite as a relative path.
    String URL = '/servlet/servlet.ImageServer?id=' + d.id + '&oid=' + orgID;  
    return URL;
  }
  
  public static DocumentUtil getInstance() {
    if (doc == null) {
      doc = new Document();
    }
    return getInstance(doc);
   }
  
  public static DocumentUtil getInstance(Document d) {
    if (instance == null) {
      instance = new DocumentUtil();
    }
    instance.doc = d;
    return instance;
  }
}