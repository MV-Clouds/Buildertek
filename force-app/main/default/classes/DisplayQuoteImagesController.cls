public class DisplayQuoteImagesController {
    public string imageURL{get;set;}
    public DisplayQuoteImagesController(){
    	imageURL = ApexPages.currentPage().getParameters().get('url').escapeHtml4();    
    }
}