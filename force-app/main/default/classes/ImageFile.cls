public with sharing class ImageFile {

  public Document doc {get; set;}
  public String url {get; set;}
  
  public ImageFile(Document docc, String urll) {
    doc = docc;
    url = urll;  
  }
   
 /* static testmethod void testImageFile() {
    // Test the getters and setters.
    Document doc = new Document();
    String url = 'url';
    
    ImageFile iFF = new ImageFile(doc, url);
    Document doc2 = iFF.doc;
    System.assert(doc2 == doc);

    String url2 = iFF.url;
    System.assert(url2 == url);
     
  }*/
  
}