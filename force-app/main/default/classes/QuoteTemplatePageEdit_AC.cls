public with sharing class QuoteTemplatePageEdit_AC {
    public string QuoteTemplatePageID{get;set;}
    public string QuoteTemplateID{get;set;}
    public boolean islineItem{get;set;}
    public boolean isError{get;set;}
    public SelectOption[] selectedContacts { get; set; }
    public SelectOption[] allContacts { get; set; }
    // public boolean isAttach{get;set;}

    public list<buildertek__Quote_Lineitem_Fields__c> LineItemsList{get;set;}
    public buildertek__DocTemplate_Page__c QuoteTemplatePageInfo{get;set;}
    
    public List<string> leftselected{get;set;}
    public List<string> rightselected{get;set;}
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    
    public Map<String, String> FieldMap{get;set;}
    public Map<String, Schema.DisplayType> FieldDataTypeMap{get;set;}
    public string Type;
    
    public SelectOption[] leftOptions { get; set; }
    public SelectOption[] rightOptions { get; set; }
    
    ApexPages.standardController m_sc = null;
    public QuoteTemplatePageEdit_AC(ApexPages.StandardController controller){
        selectedContacts = new List<SelectOption>();
        allContacts = new List<SelectOption>();
        m_sc = controller;
        system.debug('m_sc---->'+m_sc);
        LineItemsList = new list<buildertek__Quote_Lineitem_Fields__c>();
        QuoteTemplatePageInfo = new buildertek__DocTemplate_Page__c();
        
        leftselected = new List<String>();
        rightselected = new List<String>();  
        FieldMap = new Map<String, String>();
        FieldDataTypeMap = new Map<String, Schema.DisplayType>();
        
        QuoteTemplateID = ApexPages.currentPage().getParameters().get('retURL').escapeHtml4();
        QuoteTemplatePageID = ApexPages.currentPage().getParameters().get('id').escapeHtml4();

        // isAttach = false;
        string str = '/';
        QuoteTemplatePageID = QuoteTemplatePageID.replace(str, '');
        if(QuoteTemplateID != null){
        QuoteTemplateID = QuoteTemplateID.replace(str, '');
        }
        
          if (Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_API_Name__c.isAccessible() && 
              Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__DocTemplate_Page__c.isAccessible() &&
              Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_Name__c.isAccessible() && 
              Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Col_Width__c.isAccessible() &&
              Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Quote_Template__c.isAccessible()){
                LineItemsList = [Select Id,
                                        buildertek__Field_API_Name__c,
                                        buildertek__Field_Name__c,
                                        buildertek__Quote_Template__c,
                                        buildertek__DocTemplate_Page__c,
                                        buildertek__Col_Width__c 
                                        From buildertek__Quote_Lineitem_Fields__c 
                                        Where buildertek__DocTemplate_Page__c =: QuoteTemplatePageID 
                                        order by buildertek__Sort_Order__c ASC];
              }
            if(LineItemsList.size() == 0){
            islineItem = false; 
        }
        else{
        for(buildertek__Quote_Lineitem_Fields__c ll:LineItemsList){ 
        rightvalues.add(ll.Field_Name__c);
        selectedContacts.add(new SelectOption(ll.Field_Name__c, ll.Field_Name__c));
        }
        
            islineItem = true;      
        }
        list<buildertek__Quote_Template__c> quoteTemplateCheck;
        if (Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.Id.isAccessible() && 
            Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__DocTemplate_Page__c.isAccessible() && 
            Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Template_Page_Brake__c.isAccessible() && 
            Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Attachments__c.isAccessible() && 
            Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Page_Sort_order__c.isAccessible()
            && Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__LineItems__c.isAccessible()&& 
            Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Doc_Template__c.isAccessible() && 
            Schema.sObjectType.buildertek__Quote_Template__c.fields.Id.isAccessible() && 
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Format__c.isAccessible()
            ){
            QuoteTemplatePageInfo = [Select Id,
                                            buildertek__Page_Sort_order__c,
                                            buildertek__Attachments__c,
                                            buildertek__LineItems__c,
                                            buildertek__Doc_Template__r.id,
                                            buildertek__Doc_Template__r.buildertek__Template_Format__c,
                                            buildertek__Doc_Template__c,
                                            buildertek__DocTemplate_Page__c,
                                            buildertek__Template_Page_Brake__c 
                                            From buildertek__DocTemplate_Page__c 
                                            Where id =: QuoteTemplatePageID];
        }
         if (Schema.sObjectType.buildertek__Quote_Template__c.fields.Id.isAccessible() && 
            Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Format__c.isAccessible()){
            quoteTemplateCheck = [Select id,buildertek__Template_Format__c From buildertek__Quote_Template__c Where id=:QuoteTemplatePageID];
        }
         type='';
        list<ApexClass> cs;
        if (Schema.sObjectType.ApexClass.fields.NamespacePrefix.isAccessible() && Schema.sObjectType.ApexClass.fields.Name.isAccessible()) {
         cs =[select NamespacePrefix,Name from ApexClass Where name ='NewQuoteTemplate_AC' limit 1];
        }
        if(cs.size() == 0){
            type = type;
        }
        else{
           if(cs[0].NamespacePrefix !=null)
            type = cs[0].NamespacePrefix+'__';
        }
        if(quoteTemplateCheck.size() == 0 ){
            QuoteTemplateID = QuoteTemplatePageInfo.Doc_Template__r.id;
            if(QuoteTemplatePageInfo.Doc_Template__r.buildertek__Template_Format__c == 'Quote')
            type=type+'buildertek__Quote_Item__c';
            if(QuoteTemplatePageInfo.Doc_Template__r.buildertek__Template_Format__c == 'Contract')
            type=type+'buildertek__Contract_Item__c';
            /*if(QuoteTemplatePageInfo.Doc_Template__r.Template_Format__c == 'Sales Order')
            type=type+'Sales_Order_Line__c';
            
            if(QuoteTemplatePageInfo.Doc_Template__r.Template_Format__c == 'Shipment'){
                type=type+'Shipment_Line__c';
            }
            if(QuoteTemplatePageInfo.Doc_Template__r.Template_Format__c == 'Purchase Order'){
                type=type+'Purchase_Order_Line__c';
            }
            if(QuoteTemplatePageInfo.Doc_Template__r.Template_Format__c == 'Invoice'){
                type=type+'Invoice_Line__c';
            }
            if(QuoteTemplatePageInfo.Doc_Template__r.Template_Format__c == 'Credit Memo'){
                type=type+'Credit_Memo_Line__c';
            } */           
        }
        else{
            if(QuoteTemplatePageInfo.Doc_Template__r.buildertek__Template_Format__c == 'Quote')
            type=type+'buildertek__Quote_Item__c';
            if(QuoteTemplatePageInfo.Doc_Template__r.buildertek__Template_Format__c == 'Contract')
            type=type+'buildertek__Contract_Item__c';
            /*if(quoteTemplateCheck[0].Template_Format__c == 'Sales Order')
            type=type+'Sales_Order_Line__c';
            
            if(quoteTemplateCheck[0].Template_Format__c == 'Shipment'){
                type=type+'Shipment_Line__c';
            }
            if(quoteTemplateCheck[0].Template_Format__c == 'Purchase Order'){
                type=type+'Purchase_Order_Line__c';
            } 
             if(quoteTemplateCheck[0].Template_Format__c == 'invoice'){
                type=type+'Invoice_Line__c';
            }   
             if(quoteTemplateCheck[0].Template_Format__c == 'Credit Memo'){
                type=type+'Credit_Memo_Line__c';
            }  */                     
        }
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        

        Schema.SObjectType systemObjectType = gd.get(type);  
        Schema.DescribeSObjectResult r= systemObjectType.getDescribe();  
        Map<String, Schema.SObjectField> M = r.fields.getMap();      
             for(Schema.SObjectField fieldAPI : M.values())  {
                   system.debug(fieldAPI.getDescribe().getName() + ' FieldMap ********** ' + fieldAPI.getDescribe().getLabel());
                   leftvalues.add(fieldAPI.getDescribe().getLabel());
                   allContacts.add(new SelectOption(fieldAPI.getDescribe().getLabel(), fieldAPI.getDescribe().getLabel()));
                   FieldMap.put(fieldAPI.getDescribe().getLabel(),fieldAPI.getDescribe().getName());
                   FieldDataTypeMap.put(fieldAPI.getDescribe().getName(),fieldAPI.getDescribe().getType()); 
              }
        system.debug('FieldMap ********** ' + FieldMap);
        for(String s1 : leftvalues){
            for(String s2 : rightvalues){
                if(s1 == s2){
                leftvalues.remove(s1);  
                }
                
            }
            
        }
        /*for(SelectOption SO : allContacts){
            for(SelectOption SO1 : selectedContacts){
                if(SO.getValue() == SO1.getValue()){
                    allContacts.remove(SO);       
                }   
            }    
        }*/
    
    }
    
    
   public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
     
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }
    
 
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>(); 
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList){
            options1.add(new SelectOption(s,s));
        }
        system.debug('options1 ---------> '+options1.size());
        return options1;
    }
    
    
    public void verifyError(){
    isError = false;
                if(QuoteTemplatePageInfo.buildertek__Page_Sort_order__c == null){
                   this.QuoteTemplatePageInfo.buildertek__Page_Sort_order__c.addError('Please Enter the template sort order.' );
                   isError = true;           
                }     
        if(islineItem == false){
                if(QuoteTemplatePageInfo.buildertek__DocTemplate_Page__c == ''){
                   this.QuoteTemplatePageInfo.buildertek__DocTemplate_Page__c.addError('Please Enter the template body.' );
                   isError = true;           
                } 
        }
        else{
                if(rightvalues.size() == 0){
                   ApexPages.Message msgAddr = new ApexPages.Message(ApexPages.severity.Error,'Please select the quote lineitem values');
                   ApexPages.addMessage(msgAddr);                  
                   isError = true;           
                }       
        }
           /* if(QuoteTemplatePageInfo.Attachments__c == true && QuoteTemplatePageInfo.Page_Sort_order__c > 0){
                this.QuoteTemplatePageInfo.Attachments__c.addError('Doesnot select Attachment Field..' );
                isError = true;
            }*/
    
    }    
    
    
    public pagereference UpdateTemplatePageInfo(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        

        Schema.SObjectType systemObjectType = gd.get(type);  
        Schema.DescribeSObjectResult r= systemObjectType.getDescribe();  
        Map<String, Schema.SObjectField> M = r.fields.getMap();      
             for(Schema.SObjectField fieldAPI : M.values())  {
                   system.debug(fieldAPI.getDescribe().getName() + ' FieldMap ********** ' + fieldAPI.getDescribe().getLabel());
                   leftvalues.add(fieldAPI.getDescribe().getLabel()); 
                   allContacts.add(new SelectOption(fieldAPI.getDescribe().getLabel(), fieldAPI.getDescribe().getLabel()));
                   FieldMap.put(fieldAPI.getDescribe().getLabel(),fieldAPI.getDescribe().getName());
                   FieldDataTypeMap.put(fieldAPI.getDescribe().getName(),fieldAPI.getDescribe().getType()); 
              }
                  
        string strsmap = FieldMap.get('Subtotal ');
        system.debug('St1sub **************** '+ strsmap);
       
        //message = 'Selected Contacts: ';
        //Boolean first = true;
        rightvalues.clear();
        for ( SelectOption so : selectedContacts ) {
            rightvalues.add(SO.getValue());    
        }
        
        
        List<buildertek__Quote_Lineitem_Fields__c> QLFList = new List<buildertek__Quote_Lineitem_Fields__c>();
        verifyError();
        if(!isError){ 
            system.debug('rightvalues -------> '+rightvalues);
            getSelectedValues();
        if((QuoteTemplatePageInfo.buildertek__DocTemplate_Page__c != null && QuoteTemplatePageInfo.buildertek__DocTemplate_Page__c != '') || rightvalues.size() != 0){
            if(islineItem){
                if(Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__LineItems__c.isUpdateable()){
                    QuoteTemplatePageInfo.buildertek__LineItems__c = true; 
                }
            }
           /* if(isAttach == true){
                system.debug('isAttachTrue--->'+isAttach);
                    QuoteTemplatePageInfo.Attachments__c = true; 
                }
                else if(isAttach == false){
                    system.debug('isAttachfalse--->'+isAttach);
                    QuoteTemplatePageInfo.Attachments__c = false; 
                }*/
            update QuoteTemplatePageInfo;
            if(islineItem){
                 integer i = 1; 
                    map<string,buildertek__Quote_Lineitem_Fields__c> qlineMap =new map<string,buildertek__Quote_Lineitem_Fields__c>();
                    for(buildertek__Quote_Lineitem_Fields__c lf : LineItemsList){
                        qlineMap.put(lf.Field_Name__c,lf);
                    }
                    
                     for(String st : rightvalues){ 
                         system.debug('St1 **************** '+ St);
                        if(qlineMap.get(st)!=null){
                            buildertek__Quote_Lineitem_Fields__c qlf = new buildertek__Quote_Lineitem_Fields__c();
                            
                                qlf.buildertek__Field_Name__c = st;
                                 system.debug(String.ValueOf(FieldDataTypeMap.get(FieldMap.get(st))) + ' St **************** '+ St);
                                if(String.ValueOf(FieldDataTypeMap.get(FieldMap.get(st))) == 'REFERENCE'){ 
                                    String str = FieldMap.get(st);  
                                   if(str.contains('__c')){
                                    str = str.substring(0, str.length() - 1);   
                                    qlf.buildertek__Field_API_Name__c = str+'r.Name';
                                    }
                                    else{
                                       str = str.substring(0, str.length() - 2);   
                                        qlf.buildertek__Field_API_Name__c = str+'.Name'; 
                                    }
                                }   
                                else{
                                    system.debug(FieldMap.get(st)  + ' Stsub **************** '+ St);
                                    if(FieldMap.get(st) != null){
                                        qlf.buildertek__Field_API_Name__c = FieldMap.get(st); 
                                    }
                                    else if((FieldMap.get(st+' ')) != null){  
                                        qlf.buildertek__Field_API_Name__c = FieldMap.get(st+' '); 
                                    }
                                }
                                qlf.buildertek__Quote_Template__c = QuoteTemplateID;
                                qlf.buildertek__DocTemplate_Page__c = QuoteTemplatePageID;
                                qlf.buildertek__Sort_Order__c = i;
                                qlf.buildertek__Col_Width__c = qlineMap.get(st).Col_Width__c;
                                qlf.buildertek__Field_Type__c = String.valueOf(FieldDataTypeMap.get(FieldMap.get(st)));
                                QLFList.add(qlf);
                                i = i+1;
                             
                        }
                        else{
                             system.debug(FieldMap.get(st) + ' St2 **************** '+ St);
                            buildertek__Quote_Lineitem_Fields__c qlf = new buildertek__Quote_Lineitem_Fields__c();
                            
                            
                            qlf.buildertek__Field_Name__c = st;
                            if(String.ValueOf(FieldDataTypeMap.get(FieldMap.get(st))) == 'REFERENCE'){ 
                                String str = FieldMap.get(st);  
                                if(str.contains('__c')){
                                    str = str.substring(0, str.length() - 1);   
                                    qlf.buildertek__Field_API_Name__c = str+'r.Name';
                                }
                                else{
                                   str = str.substring(0, str.length() - 2);   
                                    qlf.buildertek__Field_API_Name__c = str+'.Name'; 
                                }
                            }   
                            else{
                                system.debug(FieldMap.get(st)  + ' Stsub **************** '+ St);
                                    if(FieldMap.get(st) != null){
                                        qlf.buildertek__Field_API_Name__c = FieldMap.get(st); 
                                    }
                                    else if((FieldMap.get(st+' ')) != null){  
                                        qlf.buildertek__Field_API_Name__c = FieldMap.get(st+' '); 
                                    } 
                            }
                            qlf.buildertek__Quote_Template__c = QuoteTemplateID;
                            qlf.buildertek__DocTemplate_Page__c = QuoteTemplatePageID;
                            qlf.buildertek__Sort_Order__c = i;
                            qlf.buildertek__Col_Width__c = 20;
                            qlf.buildertek__Field_Type__c = String.valueOf(FieldDataTypeMap.get(FieldMap.get(st)));
                            QLFList.add(qlf);
                            i = i+1;
                          
                        }
                        
                     
                     }
                 
                 
                    if(QLFList.size() != 0){
                        if(buildertek__Quote_Lineitem_Fields__c.sObjectType.getDescribe().isDeletable()){
                            delete LineItemsList;
                        }
                    } 
                    if(Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_API_Name__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Quote_Template__c.isCreateable()&& 
                        Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__DocTemplate_Page__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Sort_Order__c.isCreateable()&&
                        Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Col_Width__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_Type__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_Name__c.isCreateable()){
                        insert QLFList;
                        }
                    
        }   
        }
        /*PageReference pr = new PageReference('/'+QuoteTemplateID);
        return pr;*/
        return m_sc.cancel(); 
        }
        return null;
    }
    
    public pagereference doCancel(){
        return m_sc.cancel(); 
    }
    
}