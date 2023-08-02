public class PRViewController {
    public String currentRecordId {get;set;}
    public PageReference redirectPage() {
        String currentPage = ApexPages.currentPage().getUrl();
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        String sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm();
        System.debug('Base URL>>' + sfdcBaseURL );
        sfdcBaseURL = sfdcBaseURL + '/lightning/r/buildertek__Pricing_Request__c/'+currentRecordId+'/view';
        PageReference pageRef = new PageReference(sfdcBaseURL);
        pageRef.setRedirect(true);
        return pageRef;
    }

}