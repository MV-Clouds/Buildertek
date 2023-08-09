public with sharing class QuoteTemplateEdit_AC {
	public string QuoteTemplateID{get;set;}
	public buildertek__Quote_Template__c quoteInfoEdit{get;set;}
	public boolean isError{get;set;}

	
	public 	QuoteTemplateEdit_AC(ApexPages.StandardController controller){
		quoteInfoEdit = new buildertek__Quote_Template__c();

		
		QuoteTemplateID = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
		string str = '/';
		QuoteTemplateID = QuoteTemplateID.replace(str, ''); 
		
		
      if (Schema.sObjectType.buildertek__Quote_Template__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Description__c.isAccessible() && 
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Footer__c.isAccessible() &&
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Body__c.isAccessible() && 
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Font_Family__c.isAccessible() &&
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Header__c.isAccessible() && 
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Show_Page_Number__c.isAccessible () && 
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Format__c.isAccessible() &&
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Show_Invoice_Shipment__c.isAccessible()) {
                      
		    quoteInfoEdit = [Select Id,
		                            buildertek__Template_Body__c,
		                            buildertek__Template_Format__c,
		                            buildertek__Show_Page_Number__c, 
		                            buildertek__Description__c, 
		                            buildertek__Template_Header__c,
		                            buildertek__Template_Footer__c,
		                            buildertek__Font_Family__c,
		                            buildertek__Show_Invoice_Shipment__c 
		                            From buildertek__Quote_Template__c 
		                            Where Id=:QuoteTemplateID];

            }	
	}
	 
     public String HeaderImage{get;set;}
	 public List<SelectOption> getImage()   
	    {
	        List<Document> DocumentList;
	        if (Schema.sObjectType.Document.fields.id.isAccessible() && Schema.sObjectType.Document.fields.Name.isAccessible()){
	    	 DocumentList = [Select Id,Name from Document limit 40000];
	        } 
	        List<SelectOption> options = new List<SelectOption>();
	        options.add(new SelectOption('','-NONE-'));
	        
		        for(Document dl:DocumentList){
			        options.add(new SelectOption(dl.Id,dl.Name));
			    }
			        
			        
	
	        return options;
	     }
	     
	public void verifyError(){
    isError = false;
			if(quoteInfoEdit.buildertek__Template_Header__c == null){
			   this.quoteInfoEdit.buildertek__Template_Header__c.addError('Please Select the template header.' );
               isError = true;           
			} 
			if(quoteInfoEdit.buildertek__Template_Footer__c == null){
			   this.quoteInfoEdit.buildertek__Template_Footer__c.addError('Please Select the template footer.' );
               isError = true;           
			}
			if(quoteInfoEdit.buildertek__Template_Body__c == null ){
			   this.quoteInfoEdit.buildertek__Template_Body__c.addError('Please Enter the template body.' );
               isError = true;           
			}
			if(quoteInfoEdit.buildertek__Template_Format__c == null){
			   this.quoteInfoEdit.buildertek__Template_Format__c.addError('Please Enter the template format.' );
               isError = true;           
			}			
			if(quoteInfoEdit.buildertek__Description__c == null || quoteInfoEdit.buildertek__Description__c == ''){
			   this.quoteInfoEdit.buildertek__Description__c.addError('Please Enter the Description.' );
               isError = true;           
			}	
				
				 			
	}	     
	     
	public pagereference UpdateQuoteInfo(){
    	verifyError();
    	if(!isError){
    	 if (Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Description__c.isUpdateable() && 
			Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Footer__c.isUpdateable() &&
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Body__c.isUpdateable() && 
			Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Font_Family__c.isUpdateable() &&
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Header__c.isUpdateable() && 
			Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Show_Page_Number__c.isUpdateable () && 
			Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Format__c.isUpdateable() &&
			Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Show_Invoice_Shipment__c.isAccessible() 
			) {
    	       update quoteInfoEdit; 
			}
	        PageReference pr = new PageReference('/'+quoteInfoEdit.Id);
	        system.debug('pr---->' + pr);
	        return pr; 
            }
    	return null;
	}

	public pagereference CancelQuoteInfo(){
 	PageReference pr = new PageReference('/'+QuoteTemplateID);
        return pr; 
	}	
	
}