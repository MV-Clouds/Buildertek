public with sharing class QuoteHeaderEdit_AC {
	public buildertek__Template_Header__c HeaderEditInfo{get;set;}
	public string HeaderID{get;set;}
	public boolean isError{get;set;}
	
	public QuoteHeaderEdit_AC(ApexPages.StandardController controller){
    	HeaderEditInfo = new buildertek__Template_Header__c();
    	
    	HeaderID = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    	if(HeaderID != null && HeaderID != ''){
    		string str = '/';
			HeaderID = HeaderID.replace(str, '');
			if (Schema.sObjectType.buildertek__Template_Header__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Template_Header__c.fields.buildertek__Template_Header__c.isAccessible() && Schema.sObjectType.buildertek__Template_Header__c.fields.buildertek__Description__c.isAccessible()) {
	    	HeaderEditInfo = [SELECT Id, buildertek__Template_Header__c, buildertek__Description__c
		                        FROM buildertek__Template_Header__c WHERE id =:HeaderID];
		    }
    	}
    	
    }
   
    
	public void verifyError(){
    isError = false;
			if(HeaderEditInfo.buildertek__Description__c == '' || HeaderEditInfo.buildertek__Description__c == null){
			   this.HeaderEditInfo.buildertek__Description__c.addError('Please Enter the Description.' );
               isError = true;           
			}
			else if(HeaderEditInfo.buildertek__Template_Header__c == ''){
			   this.HeaderEditInfo.buildertek__Template_Header__c.addError('Please Enter the template header.' );
               isError = true;           
			}	
				
				 			
	} 
	    
        public pagereference Save(){
    	verifyError();
    	if(!isError){  
        	if(Schema.sObjectType.buildertek__Template_Header__c.fields.id.isUpdateable() && Schema.sObjectType.buildertek__Template_Header__c.fields.buildertek__Template_Header__c.isUpdateable() && Schema.sObjectType.buildertek__Template_Header__c.fields.buildertek__Description__c.isUpdateable()){
            update HeaderEditInfo;
        	    }
    	PageReference pr = new PageReference('/'+HeaderEditInfo.Id);
        return pr; 
        	
    	}
    	return null;       

    }
    
    	public pagereference CancelQuoteHeader(){
     	PageReference pr = new PageReference('/'+HeaderID);
        return pr; 
    	}
    
}