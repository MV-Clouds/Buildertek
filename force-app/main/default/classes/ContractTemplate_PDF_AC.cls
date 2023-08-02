public with sharing class ContractTemplate_PDF_AC {
    
    public String contractTemplateID{get;set;}
    public String contractId{get;set;}
    public String myText {get;set;}
    public boolean hidelist{get;set;}
    public String mss {get;set;}
    public String includeId {get;set;}
    public Decimal Subtotal {get;set;}
    public Decimal Total {get;set;}
    public Decimal Markup {get;set;}
    public Decimal contractDiscount {get;set;}
    public Decimal contractTax {get;set;}
    public Decimal LineItemsSortOrder {get;set;}
    
    public Quote_Template__c contractInfoList{get;set;}
    public list<DocTemplate_Page__c> contractPageList{get;set;}
    public list<innerClass> contractTemplateInner{get;set;}
    public list<String> strList{get;set;}
    public list<buildertek__Contract_Item__c> contractLineList{get;set;}
    public list<buildertek__Contract_Item__c> contractLineItemValues{get;set;}
    public list<String> FIeldsNameList{get;set;}
    public Map<String, String> FieldAPIMap{get;set;}
    public Map<String, String> FieldTypeMap{get; set;}
    public Map<String, String> FieldWidthMap{get;set;}
    public Template_Header__c HeaderInfo{get;set;}
    public Template_Footer__c FooterInfo{get;set;}
    public string Tax{get;set;}
    public string Shipping{get;set;}
    public string Discount{get;set;}
    
    public class innerClass {
        public String StringTemplatePage{get;set;}
        public DocTemplate_Page__c TemplatePage{get;set;}  
        public innerClass(string strTemplatePage, DocTemplate_Page__c recTemplatePage){
            StringTemplatePage = strTemplatePage;
            TemplatePage = recTemplatePage;
        }
    }

    public ContractTemplate_PDF_AC(){
        Subtotal = 0;
        Total = 0;
        Markup = 0;
        contractDiscount = 0;
        contractTax = 0; 
        hidelist = true;
        contractInfoList = new Quote_Template__c();
        contractPageList = new list<DocTemplate_Page__c>();
        strList = new list<String>();
        contractTemplateInner = new List<innerClass>();
        Set<Id> qtIds = new Set<Id>();
        contractLineList = new list<buildertek__Contract_Item__c>();
        contractLineItemValues = new list<buildertek__Contract_Item__c>();
        FIeldsNameList = new list<String>();
        FieldAPIMap = new Map<String, String>();
        FieldTypeMap = new Map<String, String>();
        FieldWidthMap = new Map<String, String>();
        
        HeaderInfo = new Template_Header__c();
        FooterInfo = new Template_Footer__c();
        Tax = 'Tax';
        Shipping = 'Shipping';
        Discount = 'Discount';
        
    
             
        contractTemplateId = ApexPages.currentPage().getParameters().get('qtid').escapeHtml4();
        contractId = ApexPages.currentPage().getParameters().get('qid').escapeHtml4();
        system.debug('contractId--->'+contractId);
        if(contractId == null){
            includeId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        }else{
            includeId = contractId;
        }
        list<buildertek__Contract__c> contractList;
        system.debug('includeId ----------> '+includeId);
         if(Schema.sObjectType.buildertek__Contract__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
        	Schema.sObjectType.buildertek__Contract__c.fields.Doc_Template__c.isAccessible() ){ 
            contractList = [Select id,Doc_Template__c From buildertek__Contract__c Where id=:includeId];
        }
        system.debug('contractList -----------> '+contractList);
        if(contractList.size() > 0){
             contractId = includeId;
             contractTemplateId = contractList[0].Doc_Template__c;
        }
         if(Schema.sObjectType.Quote_Template__c.isAccessible() &&
        	Schema.sObjectType.Quote_Template__c.fields.Id.isAccessible()&&
        	Schema.sObjectType.Quote_Template__c.fields.Name.isAccessible()&&
        	Schema.sObjectType.Quote_Template__c.fields.Template_Body__c.isAccessible() &&
        	Schema.sObjectType.Quote_Template__c.fields.Template_Header__c.isAccessible() &&
        	Schema.sObjectType.Quote_Template__c.fields.Show_Page_Number__c.isAccessible() &&
        	Schema.sObjectType.Quote_Template__c.fields.Template_Footer__c.isAccessible() &&
        	Schema.sObjectType.Quote_Template__c.fields.Font_Family__c.isAccessible()){
            contractInfoList = [Select Id,Name,Template_Body__c,Template_Header__c,Show_Page_Number__c,Template_Footer__c,Font_Family__c From Quote_Template__c Where Id=:contractTemplateId];
        	}
        if(contractInfoList != null){
            system.debug('contractInfoList Id -------> '+contractInfoList.Id);
            if(Schema.sObjectType.DocTemplate_Page__c.isAccessible() &&
        	Schema.sObjectType.DocTemplate_Page__c.fields.Id.isAccessible()&&
        	Schema.sObjectType.DocTemplate_Page__c.fields.DocTemplate_Page__c.isAccessible()&&
        	Schema.sObjectType.DocTemplate_Page__c.fields.Template_Page_Brake__c.isAccessible() &&
        	Schema.sObjectType.DocTemplate_Page__c.fields.Page_Sort_order__c.isAccessible() &&
        	Schema.sObjectType.DocTemplate_Page__c.fields.Attachments__c.isAccessible()){
            contractPageList = [Select Id,DocTemplate_Page__c,Template_Page_Brake__c,Page_Sort_order__c,Attachments__c From DocTemplate_Page__c Where Doc_Template__c=:contractInfoList.Id order by Page_Sort_order__c ASC];
        	}
        	    
        	}
        MergeData_CTR md = new MergeData_CTR();
        md.QuoteTemplateId = contractInfoList.Id;
        md.SObjectName = 'buildertek__Contract__c';
        md.QuoteID = contractId;
        
        
        
        contractInfoList.Template_Body__c = md.m_MergeData(contractInfoList.Template_Body__c);
        /*header*/
        list<Template_Header__c> headerList;
         if(Schema.sObjectType.Template_Header__c.fields.Id.isAccessible() &&
        	Schema.sObjectType.Template_Header__c.fields.Template_Header__c.isAccessible()){
            headerList = [Select id,Template_Header__c From Template_Header__c Where id =:contractInfoList.Template_Header__c];
        }
        system.debug('headerlist ---------> '+headerList[0].Template_Header__c);
        system.debug('contractInfoList  ---------> '+contractInfoList.Template_Header__c);
        if(headerList.size() != 0){
            HeaderInfo.Template_Header__c = md.m_MergeData(headerList[0].Template_Header__c);
        }
        
        /*footer*/
        list<Template_Footer__c> footerList ;
        if(Schema.sObjectType.Template_Footer__c.fields.Id.isAccessible() &&
        	Schema.sObjectType.Template_Footer__c.fields.Template_Footer__c.isAccessible()){
            footerList = [Select id,Template_Footer__c From Template_Footer__c Where id =:contractInfoList.Template_Footer__c];
        }
        system.debug('footerList ----------> '+footerList[0].Template_Footer__c);
        system.debug('contractInfoList footerList ----------> '+contractInfoList.Template_Footer__c);
            if(footerList.size() != 0){
                FooterInfo.Template_Footer__c = md.m_MergeData(footerList[0].Template_Footer__c);
            }
        system.debug('contractPageList ----------> '+contractPageList);    
        for(DocTemplate_Page__c qp:contractPageList){
            system.debug('Doc Temp Page -------> '+qp.DocTemplate_Page__c);
            if(qp.DocTemplate_Page__c != null){
                strList.add(md.m_MergeData(qp.DocTemplate_Page__c));
                contractTemplateInner.add(new innerclass(md.m_MergeData(qp.DocTemplate_Page__c), qp));
            }
            else{
                if(qp.Page_Sort_order__c != null){
                    LineItemsSortOrder = qp.Page_Sort_order__c;
                }
                qtIds.add(qp.Id);
            }
            
        }
        
        system.debug('qtIds --------> '+qtIds);
        if(qtIds.size() != 0){
            string qry ='Select ';
            list<buildertek__Quote_Lineitem_Fields__c> qlfList;
            if(Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__DocTemplate_Page__c.isAccessible() &&
        	   Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_API_Name__c.isAccessible()
        	   && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_Name__c.isAccessible() &&
        	   Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Quote_Template__c.isAccessible()
        	   && Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Sort_Order__c.isAccessible()&& 
        	   Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Field_Type__c.isAccessible() &&
        	   Schema.sObjectType.buildertek__Quote_Lineitem_Fields__c.fields.buildertek__Col_Width__c.isAccessible()){
                 qlfList = [Select Id,
                            buildertek__Field_API_Name__c,
                            buildertek__Field_Name__c,buildertek__Col_Width__c,
                            buildertek__Field_Type__c 
                            From buildertek__Quote_Lineitem_Fields__c Where buildertek__Quote_Template__c=:contractTemplateId And buildertek__DocTemplate_Page__c In:qtIds order by Sort_Order__c ASC ];
           }
            if(qlfList.size() != 0){
                for(Quote_Lineitem_Fields__c qlf:qlfList ){
                    system.debug('qlf---->'+qlf);
                    if(qlf.Field_API_Name__c != null && qlf.Field_API_Name__c != ''){
                        qry = qry + qlf.Field_API_Name__c+',';
                        FIeldsNameList.add(qlf.Field_Name__c);
                        FieldAPIMap.put(qlf.Field_Name__c,qlf.Field_API_Name__c);
                        FieldTypeMap.put(qlf.Field_Name__c, qlf.buildertek__Field_Type__c);
                        system.debug('FieldAPIMap---->'+FieldAPIMap);
                        if(qlf.Col_Width__c != null){
                        FieldWidthMap.put(qlf.Field_Name__c,string.ValueOf(qlf.Col_Width__c));
                        }
                        else{
                        FieldWidthMap.put(qlf.Field_Name__c,'0');   
                        }
                    }
                }
            }
             
            qry = qry.substring(0, qry.length() - 1);
                
            qry = qry + ' From buildertek__Contract_Item__c Where buildertek__Contract__c =: contractId';
            system.debug('qry ****************************'+ qry);
            /*if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__contract__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Total_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Description__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Line_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
				Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Reason_for_Change__c.isAccessible()){*/
            contractLineList = Database.query(String.escapeSingleQuotes(qry));
			/*	}*/
            system.debug('contractLineList ****************************'+ contractLineList);
        }
        if(FIeldsNameList.size() == 0){
            string txt = '';
            FIeldsNameList.add(txt);
            hidelist = false;
        }
        
        buildertek__Contract__c cont;
        if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_Amount__c.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_Amount_Tax_Discount_SH__c.isAccessible() &&
			Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Tax_Rate__c.isAccessible() &&
			Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Discount__c.isAccessible() &&
			Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible() ){
			                        cont  = [Select id,
                                             buildertek__Contract_Amount__c,
                                             buildertek__Contract_Amount_Tax_Discount_SH__c,
                                             buildertek__Tax_Rate__c, 
                                             buildertek__Discount__c 
                                             From buildertek__Contract__c 
                                             Where Id =: contractId ];
			}
        Subtotal = cont.buildertek__Contract_Amount__c;
        Subtotal = Subtotal.setScale(2); 
        Total = cont.buildertek__Contract_Amount_Tax_Discount_SH__c;
        Total = Total.setScale(2);
        if(cont.buildertek__Discount__c == null){
            contractDiscount = 0;    
        }else{
            contractDiscount = cont.buildertek__Discount__c;    
        }
        contractDiscount = contractDiscount.setScale(2);
        if(cont.buildertek__Discount__c == null){
            contractTax = 0;    
        }else{
            contractTax = cont.buildertek__Tax_Rate__c;    
        }
        
        contractTax = contractTax.setScale(2);
    }

}