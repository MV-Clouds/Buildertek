public with sharing class CloneDocTemplate_AC {
    public string DocTemplateID{get;set;}
    public string DocLineitemPageID{get;set;}
    public string NewDocLineitemPageID{get;set;}
    public boolean isError{get;set;}
    
    
    public buildertek__Quote_Template__c DocTemplateRec{get;set;}
    
    public CloneDocTemplate_AC(ApexPages.StandardController stdController){
        DocTemplateRec = new buildertek__Quote_Template__c();
        DocTemplateID = ApexPages.CurrentPage().getparameters().get('id').escapeHtml4();
          if (Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Footer__c.isAccessible() 
            && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Font_Family__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Format__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Show_Page_Number__c.isAccessible() 
            && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Sample_Template__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Header__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Body__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Template__c.fields.Ownerid.isAccessible()) {
        DocTemplateRec = [Select id
                                 ,buildertek__Description__c
                                 ,buildertek__Font_Family__c
                                 ,buildertek__Sample_Template__c
                                 ,buildertek__Template_Body__c
                                 ,buildertek__Template_Footer__c
                                 ,buildertek__Template_Format__c
                                 ,buildertek__Template_Header__c,
                                 buildertek__Show_Page_Number__c
                                 ,Owner.Name
                                  From buildertek__Quote_Template__c Where id=:DocTemplateID];
            }
    }
    
    public void verifyError(){
    isError = false;
            if(DocTemplateRec.buildertek__Template_Header__c == null){
               this.DocTemplateRec.Template_Header__c.addError('Please Select the template header.' );
               isError = true;           
            } 
            if(DocTemplateRec.buildertek__Template_Footer__c == null){
               this.DocTemplateRec.buildertek__Template_Footer__c.addError('Please Select the template footer.' );
               isError = true;           
            }
            if(DocTemplateRec.buildertek__Template_Body__c == '' || DocTemplateRec.buildertek__Template_Body__c == null){
               this.DocTemplateRec.buildertek__Template_Body__c.addError('Please Enter the template body.' );
               isError = true;           
            }
            if(DocTemplateRec.buildertek__Template_Format__c == null){
               this.DocTemplateRec.buildertek__Template_Format__c.addError('Please Enter the template format.' );
               isError = true;           
            }           
            if(DocTemplateRec.buildertek__Description__c == '' || DocTemplateRec.buildertek__Description__c == null){
               this.DocTemplateRec.buildertek__Description__c.addError('Please Enter the Description.' );
               isError = true;           
            }   
                
                            
    }
    
    public pagereference Save(){
        verifyError();
        if(!isError){
            buildertek__Quote_Template__c  NewTemplateRec = new buildertek__Quote_Template__c();
            if(Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Header__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Footer__c.isCreateable()
                   && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Body__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Format__c.isCreateable()
                   && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Description__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Font_Family__c.isCreateable()
                   && Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Show_Page_Number__c.isCreateable()){
                
                NewTemplateRec.buildertek__Template_Header__c = DocTemplateRec.buildertek__Template_Header__c;
                NewTemplateRec.buildertek__Template_Footer__c = DocTemplateRec.buildertek__Template_Footer__c;
                NewTemplateRec.buildertek__Template_Body__c = DocTemplateRec.buildertek__Template_Body__c;
                NewTemplateRec.buildertek__Template_Format__c = DocTemplateRec.buildertek__Template_Format__c;
                NewTemplateRec.buildertek__Description__c = DocTemplateRec.buildertek__Description__c;
                NewTemplateRec.buildertek__Font_Family__c = DocTemplateRec.buildertek__Font_Family__c;
                NewTemplateRec.buildertek__Show_Page_Number__c = DocTemplateRec.buildertek__Show_Page_Number__c;
                insert NewTemplateRec;
               }
            
            list<buildertek__DocTemplate_Page__c> DocTemplatePageList = new list<buildertek__DocTemplate_Page__c>();
            if (Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__LineItems__c.isAccessible() && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Template_Page_Brake__c.isAccessible() 
            && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Page_Sort_order__c.isAccessible() && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Doc_Template__c.isAccessible() 
            && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__DocTemplate_Page__c.isAccessible()) {
            DocTemplatePageList = [Select id,LineItems__c,Page_Sort_order__c,buildertek__Doc_Template__c,buildertek__DocTemplate_Page__c,buildertek__Template_Page_Brake__c From buildertek__DocTemplate_Page__c Where buildertek__Doc_Template__c=:DocTemplateID];
            }
            list<buildertek__DocTemplate_Page__c> NewDocTemplatePageList = new list<buildertek__DocTemplate_Page__c>();
            for(buildertek__DocTemplate_Page__c qp:DocTemplatePageList){
            buildertek__DocTemplate_Page__c NewDocTemplatePageRec = new buildertek__DocTemplate_Page__c();
            if(qp.buildertek__LineItems__c == true){
                DocLineitemPageID = qp.id;
            } 
             if(Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__DocTemplate_Page__c.isCreateable() && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Page_Sort_order__c.isCreateable()
                && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Doc_Template__c.isCreateable() && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__LineItems__c.isCreateable()
                && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Template_Page_Brake__c.isCreateable()){
                    
                NewDocTemplatePageRec.buildertek__LineItems__c = qp.buildertek__LineItems__c;
                NewDocTemplatePageRec.buildertek__Page_Sort_order__c = qp.buildertek__Page_Sort_order__c;
                NewDocTemplatePageRec.buildertek__Doc_Template__c = NewTemplateRec.id;
                NewDocTemplatePageRec.buildertek__DocTemplate_Page__c = qp.buildertek__DocTemplate_Page__c;
                NewDocTemplatePageRec.buildertek__Template_Page_Brake__c = qp.buildertek__Template_Page_Brake__c;
                NewDocTemplatePageList.add(NewDocTemplatePageRec);
             }
            
            }
            if(Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__DocTemplate_Page__c.isCreateable() && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Page_Sort_order__c.isCreateable()
                && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Doc_Template__c.isCreateable() && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__LineItems__c.isCreateable()
                && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Template_Page_Brake__c.isCreateable()){
                    insert NewDocTemplatePageList;
                }
            
            for(buildertek__DocTemplate_Page__c nqp:NewDocTemplatePageList){
                if(nqp.buildertek__LineItems__c == true){
                    NewDocLineitemPageID =nqp.id; 
                }
            }
            
            list<buildertek__Quote_Lineitem_Fields__c> QuoteLineItemList = new list<buildertek__Quote_Lineitem_Fields__c>();
            if (Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Col_Width__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.Sort_Order__c.isAccessible() 
            && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_Name__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__DocTemplate_Page__c.isAccessible() 
            && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_API_Name__c.isAccessible() &&  Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Quote_Template__c.isAccessible()) {
            QuoteLineItemList = [Select id,buildertek__Col_Width__c,buildertek__Field_API_Name__c,buildertek__Field_Name__c,buildertek__Quote_Template__c,buildertek__DocTemplate_Page__c ,buildertek__Sort_Order__c From buildertek__Quote_Lineitem_Fields__c Where buildertek__DocTemplate_Page__c =:DocLineitemPageID];
            }
            list<buildertek__Quote_Lineitem_Fields__c> NewQuoteLineItemList = new list<buildertek__Quote_Lineitem_Fields__c>();
            for(buildertek__Quote_Lineitem_Fields__c ql:QuoteLineItemList ){
                    buildertek__Quote_Lineitem_Fields__c QLF= new buildertek__Quote_Lineitem_Fields__c();
                    QLF.buildertek__Col_Width__c = ql.buildertek__Col_Width__c;
                    QLF.buildertek__Field_Name__c =ql.buildertek__Field_Name__c;
                    system.debug('&&&&'+NewTemplateRec.buildertek__Template_Format__c);
                    if(NewTemplateRec.buildertek__Template_Format__c == 'Invoice'){
                        system.debug('*****'+NewTemplateRec.buildertek__Template_Format__c);
                        if( QLF.buildertek__Field_Name__c == 'Price' || QLF.buildertek__Field_Name__c == 'Quote Price' || QLF.buildertek__Field_Name__c == 'Cost'){
                            system.debug('$$$'+QLF.buildertek__Field_Name__c);
                             QLF.buildertek__Field_Name__c = 'Price';
                            QLF.buildertek__Field_API_Name__c = 'JunoMatic__Invoice_Price__c'; 
                        }
                        else{
                        system.debug('^^^^^^^');
                         QLF.buildertek__Field_API_Name__c = ql.buildertek__Field_API_Name__c; 
                        }
                    }
                    else if(NewTemplateRec.buildertek__Template_Format__c == 'Quote'){
                        if( QLF.buildertek__Field_Name__c == 'Price' || QLF.buildertek__Field_Name__c == 'Cost'){
                            
                            QLF.buildertek__Field_Name__c = 'Quote Price';
                        QLF.buildertek__Field_API_Name__c = 'buildertek__Quote_Price__c';
                        }
                        else{
                        system.debug('^^^^^^^');
                         QLF.buildertek__Field_API_Name__c = ql.buildertek__Field_API_Name__c; 
                        }
                    }
                    else if(NewTemplateRec.Template_Format__c == 'Sales Order'){
                           if( QLF.buildertek__Field_Name__c == 'Price' || QLF.buildertek__Field_Name__c == 'Quote Price' || QLF.buildertek__Field_Name__c == 'Cost'){
                              
                                   QLF.buildertek__Field_Name__c = 'Price';
                              QLF.buildertek__Field_API_Name__c = 'JunoMatic__Sales_Order_Price__c'; 
                           }
                       else{ 
                        QLF.buildertek__Field_API_Name__c = ql.buildertek__Field_API_Name__c;
                       }
                    }
                    else if(NewTemplateRec.Template_Format__c == 'Credit Memo'){
                         if( QLF.buildertek__Field_Name__c == 'Price' || QLF.buildertek__Field_Name__c == 'Quote Price' || QLF.buildertek__Field_Name__c == 'Cost' ){
                              QLF.buildertek__Field_Name__c = 'Price';
                              QLF.buildertek__Field_API_Name__c = 'JunoMatic__Credit_Memo_Price__c'; 
                         }
                         else{
                        
                         QLF.buildertek__Field_API_Name__c = ql.buildertek__Field_API_Name__c;
                        
                         }
                    }
                    else if(NewTemplateRec.Template_Format__c == 'Purchase Order'){
                        if( QLF.buildertek__Field_Name__c == 'Price' || QLF.buildertek__Field_Name__c == 'Quote Price' ){
                            QLF.buildertek__Field_Name__c = 'Cost';
                              QLF.buildertek__Field_API_Name__c = 'JunoMatic__Cost__c';
                        }
                        else{
                        QLF.buildertek__Field_API_Name__c = ql.buildertek__Field_API_Name__c;
                        }
                    }
                    /*else if(NewTemplateRec.Template_Format__c == 'Shipment'){
                        QLF.Field_API_Name__c = ql.Field_API_Name__c;
                    }*/
                    //QLF.Field_Name__c =ql.Field_Name__c;
                    QLF.buildertek__Quote_Template__c = NewTemplateRec.id;
                    QLF.buildertek__DocTemplate_Page__c = NewDocLineitemPageID;
                    QLF.buildertek__Sort_Order__c = ql.buildertek__Sort_Order__c; 
                    NewQuoteLineItemList.add(QLF);
                    
                    system.debug('&&&&&'+QLF.buildertek__Field_API_Name__c);
                   
            }
            if(NewQuoteLineItemList.size() > 0){
                if(Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Col_Width__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__DocTemplate_Page__c.isCreateable()
                   && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_API_Name__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_Name__c.isCreateable()
                   && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Quote_Template__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Sort_Order__c.isCreateable()){
                   system.debug('*********'+NewQuoteLineItemList);
                    insert NewQuoteLineItemList;
                   }    
            }
            
            PageReference pr = new PageReference('/'+NewTemplateRec.Id);
            return pr;        
        }
        return null;
    }       
    
}