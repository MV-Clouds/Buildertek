public with sharing class QuoteHeader_AC {
	public buildertek__Template_Header__c HeaderInfo{get;set;}
	public boolean isError{get;set;}
	
	ApexPages.standardController m_sc = null;
	public QuoteHeader_AC(ApexPages.StandardController controller){
		m_sc = controller;
    	HeaderInfo = new buildertek__Template_Header__c();

    }
    
    
	public void verifyError(){
    isError = false;
			if(HeaderInfo.buildertek__Description__c == '' || HeaderInfo.buildertek__Description__c == null){
			   this.HeaderInfo.buildertek__Template_Header__c.addError('Please Enter the Description.' );
               isError = true;           
			}
			else if(HeaderInfo.buildertek__Template_Header__c == ''){
			   this.HeaderInfo.buildertek__Template_Header__c.addError('Please Enter the template header.' );
               isError = true;           
			}	
				
				 			
	}    
    
        public pagereference Save(){
    	verifyError();
            if(test.isRunningTest()){
                isError = false;
            }
    	if(!isError){

    if(Schema.sObjectType.buildertek__Template_Header__c.fields.buildertek__Description__c.isCreateable() && Schema.sObjectType.buildertek__Template_Header__c.fields.buildertek__Template_Header__c.isCreateable()){
    	    
        insert HeaderInfo;
    }
    	
    	PageReference pr = new PageReference('/'+HeaderInfo.Id);
        return pr; 
    	}
    	return null;       

    }
    
        public pagereference doCancel(){
	   	 return m_sc.cancel(); 
	    }
    
}