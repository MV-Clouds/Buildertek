public with sharing class QuoteTemplate_PDF_AC {
    
public String QuoteTemplateID{get;set;}
public String QuoteID{get;set;}
public String myText {get;set;}
public boolean hidelist{get;set;}
public String mss {get;set;}
public String includeId {get;set;}
public Decimal Subtotal {get;set;}
public Decimal Total {get;set;}
public Decimal Markup {get;set;}
public Decimal QuoteDiscount {get;set;}
public Decimal QuoteTax {get;set;}
public Decimal LineItemsSortOrder {get;set;}

public Quote_Template__c QuoteInfoList{get;set;}
public list<DocTemplate_Page__c> QuotePageList{get;set;}
public list<innerClass> quoteTemplateInner{get;set;}
public list<String> QuoteList{get;set;}
public list<Quote_Item__c> QuoteLineList{get;set;}
public list<Quote_Item__c> QuoteLineItemValues{get;set;}
public list<String> FIeldsNameList{get;set;}
public Map<String, String> FieldAPIMap{get;set;}
public Map<String, String> FieldTypeMap{get; set;}
public Map<String, String> FieldWidthMap{get;set;}
public Template_Header__c HeaderInfo{get;set;}
public Template_Footer__c FooterInfo{get;set;}
public string Tax{get;set;}
public string Shipping{get;set;}
public string Discount{get;set;}

/*public List<Attachment> AttList {get;set;}
public List<Attachment> fileId {get;set;}

public List<ContentDocumentLink> ContentDocumentLinkList {get;set;}
public List<ContentDocumentLink> ContentDocumentLinkfileId {get;set;}

public List<ContentVersion> fileAttachments{get;set;}
public List<ContentVersion> fileAttachmentRES{get;set;}*/




    
    public class innerClass {
        public String StringTemplatePage{get;set;}
        public DocTemplate_Page__c TemplatePage{get;set;}  
        public innerClass(string strTemplatePage, DocTemplate_Page__c recTemplatePage){
            StringTemplatePage = strTemplatePage;
            TemplatePage = recTemplatePage;
        }
    }

public QuoteTemplate_PDF_AC(){
    
    
    
    
   // try{
        
    Subtotal = 0;
    Total = 0;
    Markup = 0;
    QuoteDiscount = 0;
    QuoteTax = 0; 
    hidelist = true;
    QuoteInfoList = new Quote_Template__c();
    QuotePageList = new list<DocTemplate_Page__c>();
    QuoteList = new list<String>();
    quoteTemplateInner = new List<innerClass>();
    Set<Id> qtIds = new Set<Id>();
    QuoteLineList = new list<Quote_Item__c>();
    QuoteLineItemValues = new list<Quote_Item__c>();
    FIeldsNameList = new list<String>();
    FieldAPIMap = new Map<String, String>();
    FieldTypeMap = new Map<String, String>();
    FieldWidthMap = new Map<String, String>();
    
    HeaderInfo = new Template_Header__c();
    FooterInfo = new Template_Footer__c();
    Tax = 'Tax';
    Shipping = 'Shipping';
    Discount = 'Discount';
    

         
    QuoteTemplateID = ApexPages.currentPage().getParameters().get('qtid').escapeHtml4();
    QuoteID = ApexPages.currentPage().getParameters().get('qid').escapeHtml4();
    system.debug('QuoteID--->'+QuoteID);
    if(QuoteID == null){
    includeId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    list<Quote__c> quoteList;
    if (Schema.sObjectType.Quote__c.fields.Id.isAccessible() && 
        Schema.sObjectType.Quote__c.fields.Doc_Template__c.isAccessible()){
    quoteList = [Select id,Doc_Template__c From Quote__c Where id=:includeId];
    }
         if(quoteList.size() > 0){
         QuoteID = includeId;
         QuoteTemplateID = quoteList[0].Doc_Template__c;
         }
    }
    
    
      if (Schema.sObjectType.Quote_Template__c.fields.Id.isAccessible() && 
            Schema.sObjectType.Quote_Template__c.fields.Name.isAccessible() && 
            Schema.sObjectType.Quote_Template__c.fields.Template_Footer__c.isAccessible() &&
            Schema.sObjectType.Quote_Template__c.fields.Template_Body__c.isAccessible() && 
            Schema.sObjectType.Quote_Template__c.fields.Font_Family__c.isAccessible() &&
            Schema.sObjectType.Quote_Template__c.fields.Template_Header__c.isAccessible() &&
            Schema.sObjectType.Quote_Template__c.fields.Show_Page_Number__c.isAccessible() ){
        
    
            QuoteInfoList = [Select Id,
                                    Name,
                                    Template_Body__c,
                                    Template_Header__c,
                                    Show_Page_Number__c,
                                    Template_Footer__c,
                                    Font_Family__c 
                                    From Quote_Template__c 
                                    Where Id=:QuoteTemplateID];
     }
    if(QuoteInfoList != null){
          
    // if (Schema.sObjectType.DocTemplate_Page__c.fields.DocTemplate_Page__c.isAccessible() && Schema.sObjectType.DocTemplate_Page__c.fields.Template_Page_Brake__c.isAccessible() && Schema.sObjectType.DocTemplate_Page__c.fields.Page_Sort_order__c.isAccessible()){
        
        system.debug('QuoteInfoList Id -------> '+QuoteInfoList.Id);
         if(Schema.sObjectType.DocTemplate_Page__c.isAccessible() &&
        	Schema.sObjectType.DocTemplate_Page__c.fields.Id.isAccessible()&&
        	Schema.sObjectType.DocTemplate_Page__c.fields.DocTemplate_Page__c.isAccessible()&&
        	Schema.sObjectType.DocTemplate_Page__c.fields.Template_Page_Brake__c.isAccessible() &&
        	Schema.sObjectType.DocTemplate_Page__c.fields.Page_Sort_order__c.isAccessible() &&
        	Schema.sObjectType.DocTemplate_Page__c.fields.Attachments__c.isAccessible()){
        	    
            QuotePageList = [Select Id,
                                    DocTemplate_Page__c,
                                    Template_Page_Brake__c,
                                    Page_Sort_order__c,
                                    Attachments__c 
                                    From DocTemplate_Page__c 
                                    Where Doc_Template__c=:QuoteInfoList.Id 
                                    order by Page_Sort_order__c ASC];
        }
    }
    // }
    
    MergeData_CTR md = new MergeData_CTR();
    md.QuoteTemplateId = QuoteInfoList.Id;
    md.SObjectName = 'Quote__c';
    md.QuoteID = QuoteID;
    
    
    
    QuoteInfoList.Template_Body__c = md.m_MergeData(QuoteInfoList.Template_Body__c);
    /*header*/
    list<Template_Header__c> headerList;
     if (Schema.sObjectType.Template_Header__c.fields.Template_Header__c.isAccessible() && 
        Schema.sObjectType.Template_Header__c.fields.id.isAccessible() && 
        Schema.sObjectType.Template_Header__c.fields.Template_Header__c.isAccessible()){

        headerList = [Select id,Template_Header__c From Template_Header__c Where id =:QuoteInfoList.Template_Header__c];
        system.debug('headerlist ---------> '+headerList[0].Template_Header__c);
        system.debug('QuoteInfoList  ---------> '+QuoteInfoList.Template_Header__c);
     }
        if(headerList.size() != 0){
            HeaderInfo.Template_Header__c = md.m_MergeData(headerList[0].Template_Header__c);
        }
    
    /*footer*/
    list<Template_Footer__c> footerList ;
 if (Schema.sObjectType.Template_Footer__c.fields.Id.isAccessible() && 
        Schema.sObjectType.Template_Footer__c.fields.Template_Footer__c.isAccessible()){

     footerList = [Select id,Template_Footer__c From Template_Footer__c Where id =:QuoteInfoList.Template_Footer__c];
 } 
    system.debug('footerList ----------> '+footerList[0].Template_Footer__c);
    system.debug('QuoteInfoList footerList ----------> '+QuoteInfoList.Template_Footer__c);
        if(footerList.size() != 0){
            FooterInfo.Template_Footer__c = md.m_MergeData(footerList[0].Template_Footer__c);
        }
    system.debug('QuotePageList ----------> '+QuotePageList);    
    for(DocTemplate_Page__c qp:QuotePageList){
        system.debug('Doc Temp Page -------> '+qp.DocTemplate_Page__c);
        if(qp.DocTemplate_Page__c != null){
            
            
        QuoteList.add(md.m_MergeData(qp.DocTemplate_Page__c));
        quoteTemplateInner.add(new innerclass(md.m_MergeData(qp.DocTemplate_Page__c), qp));
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
     list<Quote_Lineitem_Fields__c> qlfList;
      if (Schema.sObjectType.Quote_Lineitem_Fields__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Quote_Lineitem_Fields__c.fields.Field_API_Name__c.isAccessible() && 
            Schema.sObjectType.Quote_Lineitem_Fields__c.fields.Field_Name__c.isAccessible() &&  
            Schema.sObjectType.Quote_Lineitem_Fields__c.fields.Col_Width__c.isAccessible() &&
            Schema.sObjectType.Quote_Lineitem_Fields__c.fields.buildertek__Field_Type__c.isAccessible() &&
            Schema.sObjectType.Quote_Lineitem_Fields__c.fields.Sort_Order__c.isAccessible()) {
          qlfList = [Select Id,
                            Field_API_Name__c,
                            Field_Name__c,
                            Col_Width__c,
                            buildertek__Field_Type__c 
                            From Quote_Lineitem_Fields__c 
                            Where Quote_Template__c=:QuoteTemplateID 
                            And DocTemplate_Page__c In:qtIds 
                            order by Sort_Order__c ASC ];
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
            
            qry = qry + ' From Quote_Item__c Where buildertek__Quote__c =: QuoteID';
            system.debug('qry ****************************'+ qry);
  /*  If(Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_City__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_Country__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_Name__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_State__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_Street__c.isAccessible()&&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Bill_To_Zip_Code__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Confidence_of_Contract_COC__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__ContactId__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Date_Sent_To_Customer__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Discount__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Doc_Template__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Email_Body__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Email_Subject__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Email_Template__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Expires_On__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Grand_Total__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Gross_Margin__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Gross_Profit__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Group_Line_Items__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__List_Total__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Markup__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Markup_Amount__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Net_Total_Price__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Opportunity__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Payment_Terms__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Primary__c.isAccessible()&&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Product__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Profit_Margin__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Project__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Quote_Number__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Quote_Amount__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Primary_Contact__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Description__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Sales_Rep__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Service_Request__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_City__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_Country__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_Name__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_State__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_Street__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Ship_To_Zip_Code__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Shipping_and_Handling__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__SignatureBase64__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Start_Date__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Status__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Subtotal__c.isAccessible()&&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Tax__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Total__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Total_Costs__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Type__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Unit_Price__c.isAccessible() &&
   Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Version_Number__c.isAccessible() ){*/
            QuoteLineList = Database.query(qry);
            system.debug('QuoteLineList ****************************'+ QuoteLineList);
   /*}*/
            }
            if(FIeldsNameList.size() == 0){
            string txt = '';
            FIeldsNameList.add(txt);
            hidelist = false;
            }
            Quote__c Qt;
     if (Schema.sObjectType.Quote__c.fields.Id.isAccessible() && 
            Schema.sObjectType.Quote__c.fields.buildertek__Subtotal__c.isAccessible() &&
           Schema.sObjectType.Quote__c.fields.buildertek__Total__c.isAccessible() &&
          Schema.sObjectType.Quote__c.fields.buildertek__Grand_Total__c.isAccessible() && 
          Schema.sObjectType.Quote__c.fields.buildertek__Tax__c.isAccessible() && 
          Schema.sObjectType.Quote__c.fields.buildertek__Discount__c.isAccessible() &&
          Schema.sObjectType.Quote__c.fields.buildertek__Markup__c.isAccessible()) {
         
         Qt = [Select id,
                    buildertek__Subtotal__c,
                    buildertek__Total__c, 
                    buildertek__Grand_Total__c, 
                    buildertek__Markup__c, 
                    buildertek__Tax__c, 
                    buildertek__Discount__c 
                    From Quote__c 
                    Where Id =: QuoteID ];     
    }
  
    
    // for(Quote_Item__c ql:QuoteLineItemValues){
    //     if(ql.Product__r.Product_Type__c != Tax && ql.Product__r.Product_Type__c != Shipping && ql.Product__r.Product_Type__c != Discount ){
    //         if(ql.Extended_Total__c != null){
                if(Qt.buildertek__Subtotal__c != null){
                    Subtotal = Qt.buildertek__Subtotal__c;    
                }else{
                    Subtotal = 0;
                }
                
                Subtotal = Subtotal.setScale(2); 
                if(Qt.buildertek__Grand_Total__c != null){
                    Total = Qt.buildertek__Grand_Total__c;    
                }else{
                    Total = 0;
                }
                if(Qt.buildertek__Markup__c != null){
                    Markup = Qt.buildertek__Markup__c;    
                }else{
                    Markup = 0;
                }
                
                Markup = Markup.setScale(2);
                if(Qt.buildertek__Discount__c != null){
                    QuoteDiscount = Qt.buildertek__Discount__c;    
                }else{
                    QuoteDiscount = 0;
                }
                
                QuoteDiscount = QuoteDiscount.setScale(2);
                if(Qt.buildertek__Tax__c != null){
                    QuoteTax = Qt.buildertek__Tax__c;        
                }else{
                    QuoteTax = 0;
                }
                
                QuoteTax = QuoteTax.setScale(2);
    //         }

    //     }
    //     else{
    //         if(ql.Extended_Total__c != null){
    //         Total = Total + ql.Extended_Total__c;
    //         }

    //     }
        
    // }
    Total =  Total; 
    Total = Total.setScale(2);   
//}
// catch (Exception  e) {
//         System.debug('ERROR:' + e);
//      }
}

    
}