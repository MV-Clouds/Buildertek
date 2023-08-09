public with sharing class QuoteFooterEdit_AC {
	public buildertek__Template_Footer__c FooterEditInfo{get;set;}
	public string FooterID{get;set;}
	public boolean isError{get;set;}
	
	public QuoteFooterEdit_AC(ApexPages.StandardController controller){
    	FooterEditInfo = new buildertek__Template_Footer__c();
    	
    	FooterID = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    	if(FooterID != null && FooterID != ''){
    		string str = '/';
			FooterID = FooterID.replace(str, '');
						if (Schema.sObjectType.buildertek__Template_Footer__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Template_Footer__c.fields.buildertek__Template_Footer__c.isAccessible() && Schema.sObjectType.buildertek__Template_Footer__c.fields.buildertek__Description__c.isAccessible()) {

			
	    	FooterEditInfo = [SELECT Id, buildertek__Template_Footer__c, buildertek__Description__c
		                        FROM buildertek__Template_Footer__c WHERE id =:FooterID];
	}	    }
    }
    
	public void verifyError(){
    isError = false;
			if(FooterEditInfo.buildertek__Description__c == '' || FooterEditInfo.buildertek__Description__c == null){
			   this.FooterEditInfo.buildertek__Description__c.addError('Please Enter the Description.' );
               isError = true;           
			}	
			else if(FooterEditInfo.buildertek__Template_Footer__c == ''){
			   this.FooterEditInfo.buildertek__Template_Footer__c.addError('Please Enter the template footer.' );
               isError = true;           
			}
				
				 			
	}    
    
        public pagereference Save(){
    	verifyError();
    	if(!isError){ 
    	    if(Schema.sObjectType.buildertek__Template_Footer__c.fields.buildertek__Description__c.isUpdateable() && 
    	            Schema.sObjectType.buildertek__Template_Footer__c.fields.buildertek__Template_Footer__c.isUpdateable()){
                        update FooterEditInfo;
    	            }
    	
    	PageReference pr = new PageReference('/'+FooterEditInfo.Id);
        return pr; 
    	}
    	return null;       

    }
    
    	public pagereference CancelQuoteFooter(){
     	PageReference pr = new PageReference('/'+FooterID);
        return pr; 
    	}
    
}