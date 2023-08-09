public without sharing class PDFControllerforContract {
    public String emailBody{ get; set; }

	public Id recordId{ get; set; }

	public string templateBody{ get; set; }

	public Contact con{ get; set; }
    
    public PDFControllerforContract(ApexPages.StandardController stdCon){
        if(ApexPages.currentPage().getParameters().get('id') != null){
            recordId = ApexPages.currentPage().getParameters().get('id');
        }
    }
    public PageReference generatePDF(){
            list<buildertek__ConfirmationPageSiteURL__c> settingslist = New list<buildertek__ConfirmationPageSiteURL__c>();
            settingslist = [select id, name, buildertek__SiteURL__c from buildertek__ConfirmationPageSiteURL__c where name = 'Siteurl' limit 1];
            string sites = '';
            if(settingslist.size() >0){
                sites = settingslist[0].buildertek__SiteURL__c;
            }
            PageReference pr = new PageReference(sites+'/buildertek__BT_Invoice?id='+recordId);
        system.debug('pr'+pr);
            pr.setRedirect(true);
            return pr; 
        }

}