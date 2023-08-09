public with sharing class NewQuoteTemplate_AC {
    public string QuoteTemplateID{get;set;}
    public boolean islineItem{get;set;}
    // public boolean isAttach{get;set;}
    public buildertek__DocTemplate_Page__c TemplatePageInfo{get;set;} 
    public list<buildertek__Quote_Lineitem_Fields__c>QuoteLineList{get;set;}
    public boolean isError{get;set;}
    public SelectOption[] selectedContacts { get; set; }
    public SelectOption[] allContacts { get; set; }
    public list<buildertek__Quote_Template__c> templateList { get; set;}
    
    /*For lineitems*/
    public List<string> leftselected{get;set;}
    public List<string> rightselected{get;set;}
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    
     public List<OpportunityStage> lineItemValues{get;set;}
     public Map<String, String> FieldMap{get;set;}
     public Map<String, Schema.DisplayType> FieldDataTypeMap{get;set;}
    
    ApexPages.standardController m_sc = null;
    public  NewQuoteTemplate_AC(ApexPages.StandardController controller){
        m_sc = controller;
        selectedContacts = new List<SelectOption>();
        allContacts = new List<SelectOption>();
        leftselected = new List<String>();
        rightselected = new List<String>();  
        FieldMap = new Map<String, String>();
        FieldDataTypeMap = new Map<String, Schema.DisplayType>();
        QuoteLineList = new list<buildertek__Quote_Lineitem_Fields__c>();
        
        // isAttach = false;
        islineItem = false;
        TemplatePageInfo = new buildertek__DocTemplate_Page__c();
        QuoteTemplateID = ApexPages.currentPage().getParameters().get('retURL').escapeHtml4();
        
        
        system.debug(QuoteTemplateID.length() + '***************** QuoteTemplateID '+QuoteTemplateID);    
        
        string QuoteTemplateIDs = '';
        
        if(QuoteTemplateID.length() >= 18){
            QuoteTemplateIDs = string.valueof(ApexPages.currentPage());
            String[] str = QuoteTemplateIDs.split('&');
            system.debug('***************** str '+str);  
            boolean values = true;
            for(string st: str){
                system.debug('***************** st '+st);
                if(st.contains('lkid=') && values){
                    String[] strs = st.split('=');
                    QuoteTemplateID = strs[1];
                    values = false;
                }
            }
        }
        system.debug('***************** QuoteTemplateIDs '+QuoteTemplateID);  
        string str = '/';
        if(QuoteTemplateID != Null && QuoteTemplateID != ''){
            QuoteTemplateID = QuoteTemplateID.replace(str, ''); 
        }
        if (Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Quote_Template__c.isAccessible()) {
            QuoteLineList = [Select Id From buildertek__Quote_Lineitem_Fields__c Where buildertek__Quote_Template__c=:QuoteTemplateID];
        }
        //list<buildertek__Quote_Template__c> templateList;
        
        if (Schema.sObjectType.buildertek__Quote_Template__c.fields.buildertek__Template_Format__c.isAccessible() &&
            Schema.sObjectType.buildertek__Quote_Template__c.fields.id.isAccessible()) {
            templateList = [Select id,buildertek__Template_Format__c From buildertek__Quote_Template__c Where id=:QuoteTemplateID]; 
        }
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        String type = ''; 
         list<ApexClass> cs;
     if (Schema.sObjectType.ApexClass.fields.NamespacePrefix.isAccessible() && 
         Schema.sObjectType.ApexClass.fields.name.isAccessible()) {
         cs =[select NamespacePrefix from ApexClass Where name ='NewQuoteTemplate_AC' limit 1];
     }
        if(cs[0].NamespacePrefix == null){
            type = type;
           }
        else{
            type = cs[0].NamespacePrefix+'__';
            
        }
        
        
        if(templateList.size() >0){
            if(templateList[0].buildertek__Template_Format__c == 'Quote')
            type=type+'buildertek__Quote_Item__c';
       if(templateList[0].buildertek__Template_Format__c == 'Contract')
        type=type+'buildertek__Contract_Item__c';
        
        /*if(templateList[0].buildertek__Template_Format__c == 'Shipment'){
            type=type+'Shipment_Line__c';
        }
        
         if(templateList[0].buildertek__Template_Format__c == 'Purchase Order'){
            type=type+'Purchase_Order_Line__c';
        }
        
        if(templateList[0].buildertek__Template_Format__c == 'Invoice'){
            type=type+'Invoice_Line__c';
        }
        
        if(templateList[0].buildertek__Template_Format__c == 'Credit Memo'){
            type=type+'Credit_Memo_Line__c';
        }        
        if(templateList[0].buildertek__Template_Format__c == 'Opportunity'){
            type=type+'Opportunity';
        }
        if(templateList[0].buildertek__Template_Format__c == 'Contract'){
            type=type+'Contract';
        }*/
        
        
        Schema.SObjectType systemObjectType = gd.get(type);
        system.debug('systemObjectType ----------> '+systemObjectType);
        Schema.DescribeSObjectResult r = systemObjectType.getDescribe();  
        
        Map<String, Schema.SObjectField> M = r.fields.getMap();   
        system.debug('***************** M.values() '+M.values() );   
             for(Schema.SObjectField fieldAPI : M.values())  {
                   leftvalues.add(fieldAPI.getDescribe().getLabel()); 
                   allContacts.add(new SelectOption(fieldAPI.getDescribe().getLabel(), fieldAPI.getDescribe().getLabel()));
                   FieldMap.put(fieldAPI.getDescribe().getLabel(),fieldAPI.getDescribe().getName());
                   
                   FieldDataTypeMap.put(fieldAPI.getDescribe().getName(),fieldAPI.getDescribe().getType()); 
              }  
        }
               
         unselectedvalues = new List<SelectOption>();
         List<string> tempList = new List<String>();
         system.debug('***************** leftvalues '+leftvalues );
         tempList.addAll(leftvalues);
         tempList.sort();
         system.debug('***************** tempList '+tempList );
         for(string s : tempList)
            unselectedvalues.add(new SelectOption(s,s));

         system.debug('***************** '+unselectedvalues );
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
    
 
    public List<SelectOption> unSelectedValues{get;set;}
        
    
 
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    
    public void verifyError(){
    isError = false;
                if(TemplatePageInfo.buildertek__Page_Sort_order__c == null){
                   this.TemplatePageInfo.buildertek__Page_Sort_order__c.addError('Please Enter the template sort order.' );
                   isError = true;           
                }    
        if(islineItem == false){
                if(TemplatePageInfo.buildertek__DocTemplate_Page__c == ''){
                   this.TemplatePageInfo.buildertek__DocTemplate_Page__c.addError('Please Enter the template body.' );
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
        /*if(TemplatePageInfo.LineItems__c = true && TemplatePageInfo.Attachments__c == true){
            this.TemplatePageInfo.Attachments__c.addError('Doesnot select Attachment Field..' );
               isError = true;
        }*/
        
    
    }
    
        public pagereference SaveNewQuoteTemplatePage(){
        List<buildertek__Quote_Lineitem_Fields__c> QLFList = new List<buildertek__Quote_Lineitem_Fields__c>();
        verifyError();
        //rightvalues.clear();
        for ( SelectOption so : selectedContacts ) {
            rightvalues.add(SO.getValue());    
        }
        if(!isError){       
        if((TemplatePageInfo.buildertek__DocTemplate_Page__c != null && TemplatePageInfo.buildertek__DocTemplate_Page__c != '') || rightvalues.size() != 0){
                // if(Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Doc_Template__c.isCreateable()){
                    TemplatePageInfo.buildertek__Doc_Template__c = QuoteTemplateID;
                // }
            
                if(islineItem){ 
                    // if(Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__LineItems__c.isCreateable()){
                        TemplatePageInfo.buildertek__LineItems__c = true; 
                    // }
                }
               /* if(isAttach == true){
                    TemplatePageInfo.Attachments__c = true; 
                }*/
            if(Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Doc_Template__c.isCreateable() &&
                Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Page_Sort_order__c.isCreateable() && 
                Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__LineItems__c.isCreateable() &&
                Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Attachments__c.isCreateable() && 
                Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__DocTemplate_Page__c.isCreateable() &&
                Schema.sObjectType.buildertek__DocTemplate_Page__c.fields.buildertek__Template_Page_Brake__c.isCreateable()){
                insert TemplatePageInfo;
             }
            if(islineItem){
                 integer i = 1;
                 for(String st :rightvalues){
                    
                    buildertek__Quote_Lineitem_Fields__c qlf = new buildertek__Quote_Lineitem_Fields__c();
                    
                    qlf.buildertek__Field_Name__c = st;
                    if(String.ValueOf(FieldDataTypeMap.get(FieldMap.get(st))) == 'REFERENCE'){ 
                        
                    String str = FieldMap.get(st); 
                    if(str.contains('__c') ){
                        str = str.substring(0, str.length() - 1);   
                        qlf.buildertek__Field_API_Name__c = str+'r.Name';
                    }
                    else{
                        str = str.substring(0, str.length() - 2);
                        qlf.buildertek__Field_API_Name__c = str+'.Name';
                    }
                    }
                    else{
                    qlf.buildertek__Field_API_Name__c = FieldMap.get(st);   
                    }
                    qlf.buildertek__Quote_Template__c = QuoteTemplateID;
                    qlf.buildertek__DocTemplate_Page__c = TemplatePageInfo.id;
                    qlf.buildertek__Sort_Order__c = i;
                    qlf.buildertek__Field_Type__c = String.valueOf(FieldDataTypeMap.get(FieldMap.get(st)));
                    QLFList.add(qlf);
                    i = i+1;
                      
                    }
                    if(Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__DocTemplate_Page__c.isCreateable() &&
                        Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_API_Name__c.isCreateable()
                       && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_Name__c.isCreateable() &&
                       Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Quote_Template__c.isCreateable()
                       && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Sort_Order__c.isCreateable()&& 
                       Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_Type__c.isCreateable()){
                       insert QLFList;
                       }
        }   
        }
        PageReference pr = new PageReference('/'+QuoteTemplateID);
        return pr;
        }
        return null;
        
    }
    
    public pagereference doCancel(){
    return m_sc.cancel(); 
    }
    
    
}