public class Clone_Quote_Controller {
    @AuraEnabled
    public static buildertek__Quote__c getQuote(Id quoteId) {
        System.debug('Quote Id *********'+quoteId);
        return [select Id, buildertek__Version_Number__c from buildertek__Quote__c where id=:quoteId Limit 1];
    }
    @AuraEnabled
    public static String cloneQuote(Id quoteId,String versionValue,String reason) {
        String msg;
        String msg1;
        if(versionValue!=null){
            List<buildertek__Quote__c> quotecopy=new List<buildertek__Quote__c>();
            List<buildertek__Quote_Item__c> quoteLinesListcopy=new List<buildertek__Quote_Item__c>();
            buildertek__Quote__c parentQuote=[SELECT Id,
                                              OwnerId, 
                                              IsDeleted, 
                                              Name,
                                              RecordTypeId, 
                                              buildertek__Description__c,
                                              buildertek__Quote_Amount__c,
                                              buildertek__Status__c,
                                              buildertek__Project__c, 
                                              buildertek__Auto_Number__c, 
                                              buildertek__Primary__c, buildertek__Markup__c,
                                              buildertek__Profit_Margin__c, 
                                              buildertek__Payment_Terms__c, 
                                              buildertek__Expires_On__c, 
                                              buildertek__Sales_Rep__c, 
                                              buildertek__Primary_Contact__c, 
                                              buildertek__Start_Date__c, 
                                              buildertek__Bill_To_Name__c,
                                              buildertek__Bill_To_Street__c,
                                              buildertek__Bill_To_City__c, 
                                              buildertek__Bill_To_State__c,
                                              buildertek__Bill_To_Zip_Code__c, 
                                              buildertek__Bill_To_Country__c, 
                                              buildertek__Ship_To_Name__c,
                                              buildertek__Ship_To_Street__c,
                                              buildertek__Ship_To_City__c, 
                                              buildertek__Ship_To_State__c,
                                              buildertek__Ship_To_Zip_Code__c,
                                              buildertek__Product__c,
                                              buildertek__Group_Line_Items__c, 
                                              buildertek__Opportunity__c,
                                              buildertek__Email_Body__c, 
                                              buildertek__Email_Subject__c, 
                                              buildertek__Unit_Price__c, 
                                              buildertek__Ship_To_Country__c, 
                                              buildertek__SignatureBase64__c, 
                                              buildertek__Total_Costs__c, 
                                              buildertek__List_Total__c,
                                              buildertek__Auto_Number1__c, 
                                              buildertek__Quote_Number__c, 
                                              buildertek__Tax__c, 
                                              buildertek__Shipping_and_Handling__c, 
                                              buildertek__Subtotal__c, 
                                              buildertek__Discount__c, 
                                              buildertek__Total__c, 
                                              buildertek__Grand_Total__c,
                                              buildertek__Service_Request__c,
                                              buildertek__Version_Number__c, 
                                              buildertek__Gross_Profit__c,
                                              buildertek__Net_Total_Price__c,
                                              buildertek__Gross_Margin__c, 
                                              buildertek__Confidence_of_Contract_COC__c, 
                                              buildertek__Type__c,
                                              buildertek__ContactId__c, 
                                              buildertek__Markup_Amount__c, 
                                              buildertek__Doc_Template__c, 
                                              buildertek__Email_Template__c,
                                              buildertek__Bill_To_Email_Address__c, 
                                              buildertek__Bill_To_Home_Phone__c,
                                              buildertek__Date_Sent_To_Customer__c, 
                                              buildertek__Aging__c,
                                              buildertek__Bill_To_Cell_Phone__c, 
                                              buildertek__Date_Accepted_by_Customer__c,
                                              buildertek__Section_I__c, 
                                              buildertek__Section_II__c, 
                                              buildertek__Section_III__c, 
                                              buildertek__Rollup_by_Group__c,
                                              buildertek__Roll_Up__c, 
                                              buildertek__Customer_Accepted_Date__c,
                                              buildertek__OppToQuoteId__c, 
                                              buildertek__Customer_accepted_amount__c, 
                                              buildertek__Customer_Quote_Amount__c,
                                              buildertek__Total_Customer_Quote_Amount__c,
                                              buildertek__Create_Contract_on_Quote_Acceptance__c,
                                              buildertek__Default_Markup__c, buildertek__TemplateId__c,
                                              buildertek__Memo__c, buildertek__Rejection_Reason__c, 
                                              buildertek__Quote_Override_Amount__c,
                                              buildertek__Date_Proposal_Opened_Last__c,
                                              buildertek__To_Emails__c, buildertek__Notes__c, 
                                              buildertek__Reason_for_New_Version__c 
                                              FROM buildertek__Quote__c where id=:quoteId Limit 1];
           
            try{
                buildertek__Quote__c cloneQuote=parentQuote.clone(false,true,true,false);  
                cloneQuote.buildertek__Version_Number__c=versionValue;
                cloneQuote.buildertek__Reason_for_New_Version__c=reason;
                quotecopy.add(cloneQuote);
                if(!quotecopy.isEmpty()){
                    insert quotecopy;
                    msg=quotecopy[0].Id;
                }
            }catch(Exception ex){
                msg1=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
            }  
            List<buildertek__Quote_Item__c> quoteLinesList=[SELECT Id, 
                                                            IsDeleted,
                                                            Name, 
                                                            buildertek__Item_Name__c,
                                                            buildertek__Description__c,
                                                            buildertek__Quantity__c,
                                                            buildertek__Unit_Price__c, 
                                                            buildertek__Total_Cost__c, 
                                                            buildertek__Quote__c, 
                                                            buildertek__Cost_Code__c, 
                                                            buildertek__Auto_Number__c, 
                                                            buildertek__RFQ__c, 
                                                            buildertek__Product__c,
                                                            buildertek__Grouping__c, 
                                                            buildertek__UOM__c,
                                                            buildertek__Vendor__c, 
                                                            buildertek__List_Unit_Price__c,
                                                            buildertek__Markup__c,
                                                            buildertek__Additional_Discount__c, 
                                                            buildertek__Unit_Cost__c, 
                                                            buildertek__List_Total__c, 
                                                            buildertek__Net_Total_Price__c, 
                                                            buildertek__Net_Unit__c, 
                                                            buildertek__Applied_Markup__c,
                                                            buildertek__Net_Total__c, 
                                                            buildertek__MFG_Discount__c, 
                                                            buildertek__Pricing_Method__c,
                                                            buildertek__Discount__c, 
                                                            buildertek__Profit_Margin__c,
                                                            buildertek__Gross_Profit__c,
                                                            buildertek__Notes__c, 
                                                            buildertek__Purchase_Order__c, 
                                                            buildertek__Status__c, 
                                                            buildertek__Sub_Group__c, 
                                                            buildertek__Priority__c
                                                            FROM buildertek__Quote_Item__c where buildertek__Quote__c=:quoteId];
            try{
                for(buildertek__Quote_Item__c ql:quoteLinesList){
                    buildertek__Quote_Item__c quoutelinecopy=ql.clone(false,true);
                    quoutelinecopy.buildertek__Quote__c=quotecopy[0].Id;
                    quoteLinesListcopy.add(quoutelinecopy);
                }
                if(!quoteLinesListcopy.isEmpty()){
                    insert quoteLinesListcopy;            
                }
            }catch(Exception ex){
                msg1=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();                         
            }        
        }
        return msg;  
    }
}