public with sharing class QuoteTemplate_AC {

public buildertek__Quote_Template__c quoteInfo{get;set;}
public buildertek__DocTemplate_Page__c quotePageInfo{get;set;}
public boolean isError{get;set;}

ApexPages.standardController m_sc = null;
    public QuoteTemplate_AC(ApexPages.StandardController controller){
        m_sc = controller;
        quoteInfo = new buildertek__Quote_Template__c();
        quotePageInfo = new buildertek__DocTemplate_Page__c();

    }

     public String HeaderImage{get;set;}
     
     public List<SelectOption> getImage()   
        { 
             List<Document> DocumentList;
          
            DocumentList = [Select Id,Name from Document limit 40000];
            
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','-NONE-'));
            
                for(Document dl:DocumentList){
                    options.add(new SelectOption(dl.Id,dl.Name));
                }
                    
                    
    
            return options;
         }



    public void verifyError(){
    isError = false;
            if(quoteInfo.buildertek__Template_Header__c == null){
               this.quoteInfo.buildertek__Template_Header__c.addError('Please Select the template header.' );
               isError = true;           
            } 
            if(quoteInfo.buildertek__Template_Footer__c == null){
               this.quoteInfo.buildertek__Template_Footer__c.addError('Please Select the template footer.' );
               isError = true;           
            }
            if(quoteInfo.buildertek__Template_Body__c == ''){
               this.quoteInfo.buildertek__Template_Body__c.addError('Please Enter the template body.' );
               isError = true;           
            }
            if(quoteInfo.buildertek__Template_Format__c == null){
               this.quoteInfo.buildertek__Template_Format__c.addError('Please Enter the template format.' );
               isError = true;           
            }           
            if(quoteInfo.buildertek__Description__c == '' || quoteInfo.buildertek__Description__c == null){
               this.quoteInfo.buildertek__Description__c.addError('Please Enter the Description.' );
               isError = true;           
            }   
                
                            
    }
     
    
    public pagereference Save(){
        verifyError();
        if(!isError){
             
               
            
            insert quoteInfo;
            
            PageReference pr = new PageReference('/'+quoteInfo.Id);
            return pr;
                   
        }
        return null;
    }  
    
    public pagereference doCancel(){
    return m_sc.cancel(); 
    }
    
}