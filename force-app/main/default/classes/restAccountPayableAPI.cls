@RestResource(urlmapping='/restAccountPayableAPI/*')

global without sharing class restAccountPayableAPI
{
    
    @HttpGet
    global static list<buildertek__Account_Payable__c> Accountpayablerecs()
    {
        
        String AccountpayableId= RestContext.request.params.get('Id');
        System.debug('acc id--:'+AccountpayableId);
        list<buildertek__Account_Payable__c> acpayblelst = [SELECT ID , Name,
                                                            buildertek__Auto_Number1__c,
                                                            buildertek__Accounting_Period__c,
                                                            buildertek__Accounting_Year__c,
                                                            buildertek__Aging__c,
                                                            buildertek__Balance__c,
                                                            buildertek__AP_Number__c,
                                                            buildertek__Auto_Number__c,
                                                            buildertek__Contact__c,
                                                            buildertek__Cost_Code__c,
                                                            buildertek__Date_Received__c,
                                                            buildertek__Description__c,
                                                            buildertek__Discount__c,
                                                            buildertek__Due_Date__c,
                                                            buildertek__Employee__c,
                                                            buildertek__Expense_GL_Account__c,
                                                            buildertek__External_Payable__c,
                                                            buildertek__Issue_Date__c,
                                                            buildertek__Liability_GL_Account__c,
                                                            buildertek__Net_Amount__c,
                                                            buildertek__Payments__c,
                                                            buildertek__Posted__c,
                                                            buildertek__Project__c,
                                                            buildertek__Purchase_Order__c,
                                                            buildertek__Ref_No__c,
                                                            RecordTypeId,
                                                            buildertek__Status__c,
                                                            buildertek__Total__c,
                                                            buildertek__Tax__c,
                                                            buildertek__Terms__c,
                                                            buildertek__Today_Date__c,
                                                            buildertek__Total_Tax__c,
                                                            buildertek__Vendor__c,(SELECT id,
                                                                                   Name,
                                                                                   buildertek__Auto_Number1__c,
                                                                                   buildertek__Account_Payable__c,
                                                                                   buildertek__Budget_Line__c,
                                                                                   buildertek__Cost_Code__c,
                                                                                   buildertek__Description__c,
                                                                                   buildertek__Expense_GL_Account__c,
                                                                                   buildertek__Item_Title__c,
                                                                                   buildertek__Liability_GL_Account__c,
                                                                                   buildertek__Product__c,
                                                                                   buildertek__Purchase_Order_Item__c,
                                                                                   buildertek__Quantity__c,
                                                                                   buildertek__Tax__c,
                                                                                   buildertek__Total_Amount_With_Tax__c,
                                                                                   buildertek__Total_Price__c,
                                                                                   buildertek__Unit_Price__c  FROM buildertek__Account_Payable_Items__r ) FROM buildertek__Account_Payable__c where Id=:AccountpayableId ];
        
        
        return acpayblelst;
    }
    @HttpPost 
    global static String createNewAccountpayble() {  //String Accpayablejson
         String Accpayablejson = RestContext.request.requestBody.toString();
        AccountpayableJsonClass accpayabletoinsert = AccountpayableJsonClass.parse(Accpayablejson);
        list<buildertek__Account_Payable__c> accpayblst = new  list<buildertek__Account_Payable__c>();
        if(accpayabletoinsert !=null){
            for(AccountpayableJsonClass.cls_AccountPayable acclst : accpayabletoinsert.AccountPayable){
                buildertek__Account_Payable__c acc = new buildertek__Account_Payable__c();
                acc.buildertek__External_Payable__c = acclst.ExternalPayableNumber;
                if(acclst.Contact !='null')
                acc.buildertek__Contact__c = acclst.Contact;
                if(acclst.CostCode !='null')
                acc.buildertek__Cost_Code__c = acclst.CostCode;
                  if(acclst.DateRecived !=null)
                acc.buildertek__Date_Received__c = Date.valueof(acclst.DateRecived);
                if(acclst.Description !=null)
                acc.buildertek__Description__c = acclst.Description;
               if(acclst.Discount !=null)
                acc.buildertek__Discount__c = acclst.Discount;
               if(acclst.DueDate !=null)
                acc.buildertek__Due_Date__c =  Date.valueof(acclst.DueDate);
                if(acclst.Employee !='null')
                acc.buildertek__Employee__c = acclst.Employee;
               if(acclst.IssueDate !=null)
                acc.buildertek__Issue_Date__c =  Date.valueof(acclst.IssueDate);
               if(acclst.LiabilityGLAccount !='null')
                acc.buildertek__Liability_GL_Account__c = acclst.LiabilityGLAccount;
               if(acclst.Posted !=null)
                acc.buildertek__Posted__c = acclst.Posted;
               if(acclst.Project !='null')
                acc.buildertek__Project__c = acclst.Project;
               if(acclst.PurchaseOrder !='null')
                acc.buildertek__Purchase_Order__c = acclst.PurchaseOrder;
               if(acclst.RefNo !=null)
                acc.buildertek__Ref_No__c = acclst.RefNo;
               if(acclst.Status !=null)
                acc.buildertek__Status__c = acclst.Status;
               if(acclst.Tax !=null)
                acc.buildertek__Tax__c = acclst.Tax;
               if(acclst.Terms !=null)
                acc.buildertek__Terms__c = acclst.Terms;
                if(acclst.Vendor !='null')
                acc.buildertek__Vendor__c = acclst.Vendor;
                
                accpayblst.add(acc);
            }
            if(accpayblst.size() > 0){
             insert accpayblst;
            }
             Map<string, id> mapaccpayable = new Map<string, Id>();
            for(buildertek__Account_Payable__c accpayble : accpayblst){
                if(accpayble.buildertek__External_Payable__c !=null)
                mapaccpayable.put(accpayble.buildertek__External_Payable__c,accpayble.id);
            }
             list<buildertek__Account_Payable_Item__c> accpayablitem = new list<buildertek__Account_Payable_Item__c>();
             for(AccountpayableJsonClass.cls_AccountPayable acclst : accpayabletoinsert.AccountPayable){
             for(AccountpayableJsonClass.cls_AccountPayableItem acclstchild : acclst.AccountPayableItem){
                buildertek__Account_Payable_Item__c accpayitem = new buildertek__Account_Payable_Item__c();
                 if(mapaccpayable.get(acclst.ExternalPayableNumber) !=null){
                    accpayitem.buildertek__Account_Payable__c = mapaccpayable.get(acclst.ExternalPayableNumber);
                 }
                  if(acclstchild.BudgetLine !='null')	
                    accpayitem.buildertek__Budget_Line__c = acclstchild.BudgetLine;
                  if(acclstchild.CostCode !='null')
                     accpayitem.buildertek__Cost_Code__c = acclstchild.CostCode;
                     accpayitem.buildertek__Description__c = acclstchild.Description;
                    if(acclstchild.ExpenseGLAccount !='null')
                     accpayitem.buildertek__Expense_GL_Account__c = acclstchild.ExpenseGLAccount;
                     accpayitem.buildertek__Item_Title__c = acclstchild.ItemTitle;
                 	 if(acclstchild.LiabilityGLAccount !='null')
                     accpayitem.buildertek__Liability_GL_Account__c = acclstchild.LiabilityGLAccount;
                     accpayitem.Name = acclstchild.Name;
                 	 if(acclstchild.Product !='null')
                     accpayitem.buildertek__Product__c = acclstchild.Product;
                 	 if(acclstchild.PurchaseOrderItem !='null')
                     accpayitem.buildertek__Purchase_Order_Item__c = acclstchild.PurchaseOrderItem;
                     accpayitem.buildertek__Quantity__c = acclstchild.Quantity;
                     accpayitem.buildertek__Tax__c = acclstchild.Tax;
                     accpayitem.buildertek__Unit_Price__c = acclstchild.UnitPrice;
                 accpayablitem.add(accpayitem);   
                    
                 }
                      
                     
                 }
             
            
            if(accpayablitem.size()>0){
                insert accpayablitem;
            }
        }
        
        
        return 'Done';
    }
    
    
    @HttpDelete
    global static String deleteAccountpaybleId() {
       String accountpayableid= RestContext.request.params.get('Id');
        buildertek__Account_Payable__c accpayblelst = [ Select ID from buildertek__Account_Payable__c where Id=:accountpayableid];
        
        delete accpayblelst;
        
        return 'Deleted AccountPayable';
    }
    
    @HttpPut
    global static String updateAccountpayble() { //String Accpayablejson
         String Accpayablejson = RestContext.request.requestBody.toString();
         AccountpayableJsonClass accpayabletoinsert = AccountpayableJsonClass.parse(Accpayablejson);
        list<buildertek__Account_Payable__c> accpayblst = new  list<buildertek__Account_Payable__c>();
        if(accpayabletoinsert !=null){
            for(AccountpayableJsonClass.cls_AccountPayable acclst : accpayabletoinsert.AccountPayable){
                buildertek__Account_Payable__c acc = new buildertek__Account_Payable__c();
                 acc.Id = acclst.Id;
               if( acclst.ExternalPayableNumber !=null)
                acc.buildertek__External_Payable__c = acclst.ExternalPayableNumber;
                if(acclst.Contact !='null'){
                acc.buildertek__Contact__c = acclst.Contact;
                }else{
                    acc.buildertek__Contact__c = null;
                }
                if(acclst.CostCode !='null'){
                acc.buildertek__Cost_Code__c = acclst.CostCode;
                }else{
                     acc.buildertek__Cost_Code__c  = null;
                }
                if(acclst.DateRecived !=null)
                acc.buildertek__Date_Received__c = Date.valueof(acclst.DateRecived);
              //  if(acclst.Description !=null)
                acc.buildertek__Description__c = acclst.Description;
              //  if(acclst.Discount !=null)
                acc.buildertek__Discount__c = acclst.Discount;
                if(acclst.DueDate !=null)
                acc.buildertek__Due_Date__c =  Date.valueof(acclst.DueDate);
                 if(acclst.Employee !='null'){
                acc.buildertek__Employee__c = acclst.Employee;
                 }else{
                    acc.buildertek__Employee__c =null;
                }
                if(acclst.IssueDate !=null)
                acc.buildertek__Issue_Date__c =  Date.valueof(acclst.IssueDate);
                if(acclst.LiabilityGLAccount !='null'){
                acc.buildertek__Liability_GL_Account__c = acclst.LiabilityGLAccount;
                    }else{
                    acc.buildertek__Liability_GL_Account__c =null;
                }
               // if(acclst.Posted !=null)
                acc.buildertek__Posted__c = acclst.Posted;
                if(acclst.Project !='null'){
                acc.buildertek__Project__c = acclst.Project;
                }else{
                    acc.buildertek__Project__c =null;
                }
              //  if(acclst.PurchaseOrder !=null)
              //  acc.buildertek__Purchase_Order__c = acclst.PurchaseOrder;
              //  if(acclst.RefNo !=null)
                acc.buildertek__Ref_No__c = acclst.RefNo;
               // if(acclst.Status !=null)
                acc.buildertek__Status__c = acclst.Status;
               // if(acclst.Tax !=null)
                acc.buildertek__Tax__c = acclst.Tax;
              //  if(acclst.Terms !=null)
                acc.buildertek__Terms__c = acclst.Terms;
                if(acclst.Vendor !='null'){
                acc.buildertek__Vendor__c = acclst.Vendor;
                }else{
                    acc.buildertek__Vendor__c =null;
                }
                accpayblst.add(acc);
        }
            if(accpayblst.size()>0){
            update accpayblst;
            }
             Map<string, id> mapaccpayable = new Map<string, Id>();
            for(buildertek__Account_Payable__c accpayble : accpayblst){
                if(accpayble.buildertek__External_Payable__c !=null)
                mapaccpayable.put(accpayble.buildertek__External_Payable__c,accpayble.id);
            }
             list<buildertek__Account_Payable_Item__c> accpayablitem = new list<buildertek__Account_Payable_Item__c>();
             for(AccountpayableJsonClass.cls_AccountPayable acclst : accpayabletoinsert.AccountPayable){
             for(AccountpayableJsonClass.cls_AccountPayableItem acclstchild : acclst.AccountPayableItem){
                buildertek__Account_Payable_Item__c accpayitem = new buildertek__Account_Payable_Item__c();
                 if(mapaccpayable.get(acclst.ExternalPayableNumber) !=null){
                    accpayitem.buildertek__Account_Payable__c = mapaccpayable.get(acclst.ExternalPayableNumber);
                 }	
                 if(acclstchild.Id !='null'){
                 	accpayitem.Id = acclstchild.Id;
                 }
                     if(acclstchild.BudgetLine !='null'){
                        accpayitem.buildertek__Budget_Line__c = acclstchild.BudgetLine;
                     }else{
                         accpayitem.buildertek__Budget_Line__c  = null;
                     }
                     if(acclstchild.CostCode !='null'){
                         accpayitem.buildertek__Cost_Code__c = acclstchild.CostCode;
                     }else{
                         accpayitem.buildertek__Cost_Code__c  = null;
                     }
                     accpayitem.buildertek__Description__c = acclstchild.Description;
                     if(acclstchild.ExpenseGLAccount !='null'){
                         accpayitem.buildertek__Expense_GL_Account__c = acclstchild.ExpenseGLAccount;
                     }else{
                         accpayitem.buildertek__Expense_GL_Account__c = null;
                     }
                     accpayitem.buildertek__Item_Title__c = acclstchild.ItemTitle;
                 	if(acclstchild.LiabilityGLAccount !='null'){
                     accpayitem.buildertek__Liability_GL_Account__c = acclstchild.LiabilityGLAccount;
                    }else{
                        accpayitem.buildertek__Liability_GL_Account__c = null;
                    }
                     accpayitem.Name = acclstchild.Name;
                 	if(acclstchild.Product !='null'){
                     accpayitem.buildertek__Product__c = acclstchild.Product;
                    }else{
                        accpayitem.buildertek__Product__c =null;
                    }
                 if(acclstchild.PurchaseOrderItem !='null'){
                     accpayitem.buildertek__Purchase_Order_Item__c = acclstchild.PurchaseOrderItem;
                 }else{
                     accpayitem.buildertek__Purchase_Order_Item__c =null;
                 }
                     accpayitem.buildertek__Quantity__c = acclstchild.Quantity;
                     accpayitem.buildertek__Tax__c = acclstchild.Tax;
                     accpayitem.buildertek__Unit_Price__c = acclstchild.UnitPrice;
                    accpayablitem.add(accpayitem);
                 }
                         
                     
                 }
             
            
            if(accpayablitem.size()>0){
                upsert accpayablitem;
            }
        }
            
        return 'AccountPayable Updated';
    }
    
}