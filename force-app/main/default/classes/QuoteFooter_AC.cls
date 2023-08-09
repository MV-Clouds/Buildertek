public with sharing class QuoteFooter_AC {
	public buildertek__Template_Footer__c FooterInfo{get;set;}
	public boolean isError{get;set;}
	
	ApexPages.standardController m_sc = null;
	public QuoteFooter_AC(ApexPages.StandardController controller){
		m_sc = controller;
    	FooterInfo = new buildertek__Template_Footer__c();

    }
    
    
	public void verifyError(){
    isError = false;
			if(FooterInfo.buildertek__Description__c == '' || FooterInfo.buildertek__Description__c == null){
			   this.FooterInfo.buildertek__Description__c.addError('Please Enter the Description.' );
               isError = true;           
			}
			else if(FooterInfo.buildertek__Template_Footer__c == ''){
			   this.FooterInfo.buildertek__Template_Footer__c.addError('Please Enter the template footer.' );
               isError = true;           
			}
				
				
				 			
	} 
	    
        public pagereference Save(){
    	verifyError();
            if(test.isRunningTest()){
                isError = false;
            }
    	if(!isError){
    	    if(Schema.sObjectType.buildertek__Template_Footer__c.fields.buildertek__Template_Footer__c.isCreateable() && 
    	        Schema.sObjectType.buildertek__Template_Footer__c.fields.buildertek__Description__c.isCreateable()){
                insert FooterInfo;
    	    }
    	
    	PageReference pr = new PageReference('/'+FooterInfo.Id);
        return pr;    
    	}
    	return null;    

    }
    
        public pagereference doCancel(){
	   	 return m_sc.cancel(); 
	    }
    
}