public class PALienReleaseSignatureController {
   
    public string LienText{get;set;}
    public string ImageId{get;set;}
    public PALienReleaseSignatureController(){
        system.debug('VFPagee');
        LienText = ApexPages.currentPage().getParameters().get('LienText');
        ImageId = ApexPages.currentPage().getParameters().get('ImageId');
        system.debug('Text'+LienText);
        system.debug('Sign'+ImageId);
    }
}