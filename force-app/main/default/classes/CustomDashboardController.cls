public with sharing class CustomDashboardController {
    
    @AuraEnabled
    public static string getContractDetails(String projectId){
        
        List<buildertek__Project__c> projectObj=new List<buildertek__Project__c>();
        /*if(Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible()&&
        	Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()&&
        	Schema.sObjectType.buildertek__Project__c.fields.buildertek__Customer__c.isAccessible() &&
        	Schema.sObjectType.Account.fields.Phone.isAccessible() &&
        	Schema.sObjectType.Account.fields.Name.isAccessible() &&
        	Schema.sObjectType.Account.fields.buildertek__Email_Address__c.isAccessible()){*/
            projectObj=[select id,name,buildertek__Customer__r.Name,buildertek__Customer__r.Phone,buildertek__Customer__r.buildertek__Email_Address__c from buildertek__Project__c where id =:projectId];
        	/*}*/
        commuwrapper objcommuwrapper=new commuwrapper();
        
        if(projectObj.size()>0){
            objcommuwrapper.Name=projectObj[0].buildertek__Customer__r.Name;
            objcommuwrapper.Email=projectObj[0].buildertek__Customer__r.buildertek__Email_Address__c;
            objcommuwrapper.Phone=projectObj[0].buildertek__Customer__r.Phone;
        }
        
        objcommuwrapper.OpenOrderTotal=0;
        List<AggregateResult> openContract;
        /*if (Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isAccessible() && 
            Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Total_Amount_Tax__c.isAccessible() &&
            Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Status__c.isAccessible()){*/
            openContract=[select sum(buildertek__Total_Amount_Tax__c )totalValue  from buildertek__Change_Order__c  where buildertek__Project__c=:projectId And (buildertek__Status__c = 'Approved' or buildertek__Status__c = 'Pending')];
        /*}*/
        if(openContract.size()>0 && openContract[0].get('totalValue') != null){ 
            String str = '' + openContract[0].get('totalValue') ; 
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.OpenOrderTotal = Decimal.ValueOf(str) ;   
            }
        }
        
        objcommuwrapper.ApprovedOrderTotal=0;
        List<AggregateResult> approvedContract;
       /* if (Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isAccessible() && 
            Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Total_Amount_Tax__c.isAccessible() &&
            Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Status__c.isAccessible()){*/
           approvedContract=[select sum(buildertek__Total_Amount_Tax__c )totalValue  from buildertek__Change_Order__c  where buildertek__Project__c=:projectId And buildertek__Status__c = 'Customer Approved'];
          /*}*/
        if(approvedContract.size()>0 && approvedContract[0].get('totalValue') != null){ 
            String str = '' + approvedContract[0].get('totalValue') ;
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.ApprovedOrderTotal = Decimal.ValueOf(str) ;
            }
        }
        
        
        objcommuwrapper.OpenInvoiceTotal=0;
        List<AggregateResult> openInvoice;
        /*if (Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Project__c.isAccessible() && 
            Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Total_Amount_Tax__c.isAccessible() &&
            Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Status__c.isAccessible()){*/
            openInvoice=[select sum(buildertek__Total_Amount_Tax__c	 )totalValue  from buildertek__Billings__c  where buildertek__Project__c=:projectId And buildertek__Status__c = 'Open' ];
        /*}*/
        if(openInvoice.size()>0 &&  openInvoice[0].get('totalValue')  != null){
            String str = '' + openInvoice[0].get('totalValue') ;
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.OpenInvoiceTotal = Decimal.ValueOf(str) ;
            }
        }
        
        
        
        objcommuwrapper.TotalContractOrder=0;
        List<AggregateResult> contract;
        /*if (Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isAccessible() && 
            Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Total_Amount_Tax__c.isAccessible()){*/
            contract=[select sum(buildertek__Total_Amount_Tax__c )totalValue  from buildertek__Change_Order__c  where buildertek__Project__c=:projectId];
            /*}*/
        if(contract.size()>0 &&  contract[0].get('totalValue')  != null){ 
            String str = '' + contract[0].get('totalValue') ; 
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.TotalContractOrder = Decimal.ValueOf(str) ;
            }
        }
        
        objcommuwrapper.TotalInvoice=0;
        List<AggregateResult> invoiceResult;
       /*if (Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Project__c.isAccessible() && 
            Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Total_Amount_Tax__c.isAccessible()){*/
            invoiceResult =[select sum(buildertek__Total_Amount_Tax__c	 )totalValue  from buildertek__Billings__c  where buildertek__Project__c=:projectId];
        /*}*/
        if(invoiceResult.size()>0 && invoiceResult[0].get('totalValue')  != null){
            String str = '' + invoiceResult[0].get('totalValue') ;
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.TotalInvoice = Decimal.ValueOf(str) ;
            }
        }
        
        objcommuwrapper.TotalProfitLoss=0;
        List<AggregateResult> profitLossResult;
       /*if (Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Profit_Loss__c.isAccessible()){*/
        profitLossResult=[select sum(buildertek__Profit_Loss__c)totalValue  from buildertek__Budget__c];
        /*}*/
        if(profitLossResult.size()>0 &&  profitLossResult[0].get('totalValue')  != null){
            String str = '' + profitLossResult[0].get('totalValue') ; 
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.TotalProfitLoss = Decimal.ValueOf(str) ;
            }
        }
        
        objcommuwrapper.projectProfitLossTotal=0;
        List<AggregateResult> totalProfitLossResult;
        /*if (Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isAccessible() && 
            Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Estimated_Gross_Profit__c.isAccessible()){*/
            totalProfitLossResult =[select sum(buildertek__Profit_Loss__c)totalValue  from buildertek__Budget__c  where buildertek__Project__c=:projectId];
            /*}*/
        if(totalProfitLossResult.size()>0 && totalProfitLossResult[0].get('totalValue')  != null){ 
            String str = '' + totalProfitLossResult[0].get('totalValue') ; 
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.projectProfitLossTotal = Decimal.ValueOf(str) ;
            }
        }
        
        objcommuwrapper.grossProfitTotal=0;
        List<AggregateResult> totalGrossProfit;
        /*if (Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isAccessible() && 
            Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Estimated_Gross_Profit__c.isAccessible()){*/
            totalGrossProfit=[select sum(buildertek__Estimated_Gross_Profit__c)totalValue  from buildertek__Budget__c  where buildertek__Project__c=:projectId];
            /*}*/
        if(totalGrossProfit.size()>0 && totalGrossProfit[0].get('totalValue')!=null){
            String str = '' + totalGrossProfit[0].get('totalValue') ;
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.grossProfitTotal = Decimal.ValueOf(str) ;
            }
        }
        
        objcommuwrapper.CIEBTotal=0;
        List<AggregateResult> totalCIEB;
        /*if (Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isAccessible() && 
            Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Cost_In_Excess_of_Billings__c.isAccessible()){*/
            totalCIEB=[select sum(buildertek__Cost_In_Excess_of_Billings__c)totalValue  from buildertek__Budget__c  where buildertek__Project__c=:projectId];
           /* }*/
        if(totalCIEB.size()>0 && totalCIEB[0].get('totalValue')!=null ){
            String str = '' + totalCIEB[0].get('totalValue') ;
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.CIEBTotal = Decimal.ValueOf(str) ;
            }
        }
        
        objcommuwrapper.BIECTotal=0;
        List<AggregateResult> totalBIEC;
        /* if (Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isAccessible() && 
            Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Billings_In_Excess_of_Costs__c.isAccessible()){*/
            totalBIEC=[select sum(buildertek__Billings_In_Excess_of_Costs__c)totalValue  from buildertek__Budget__c  where buildertek__Project__c=:projectId];
         /*}*/
        if(totalBIEC.size()>0 && totalBIEC[0].get('totalValue')!=null){
            String str = '' + totalBIEC[0].get('totalValue') ;
            if(Decimal.ValueOf(str) != null){
                objcommuwrapper.BIECTotal = Decimal.ValueOf(str) ;
            }
        }
        
        objcommuwrapper.ApprovedOrderTotal=objcommuwrapper.ApprovedOrderTotal.setScale(0);
        objcommuwrapper.OpenOrderTotal=objcommuwrapper.OpenOrderTotal.setScale(0);
        objcommuwrapper.TotalContractOrder=objcommuwrapper.TotalContractOrder.setScale(0);
        objcommuwrapper.OpenInvoiceTotal=objcommuwrapper.OpenInvoiceTotal.setScale(0);
        objcommuwrapper.TotalInvoice=objcommuwrapper.TotalInvoice.setScale(0);
        objcommuwrapper.TotalProfitLoss=objcommuwrapper.TotalProfitLoss.setScale(0);
        objcommuwrapper.projectProfitLossTotal=objcommuwrapper.projectProfitLossTotal.setScale(2);
        objcommuwrapper.grossProfitTotal=objcommuwrapper.grossProfitTotal.setScale(2);
        objcommuwrapper.grossProfitTotal=objcommuwrapper.CIEBTotal.setScale(2);
        objcommuwrapper.grossProfitTotal=objcommuwrapper.BIECTotal.setScale(2);
        system.debug('objcommuwrapper: '+objcommuwrapper);
        string retval= system.JSON.serialize(objcommuwrapper);
        return retval;
    }
    
    public class commuwrapper{
        public string Name;
        public string Phone;
        public string Email;
        public decimal OpenOrderTotal;
        public decimal ApprovedOrderTotal;
        public decimal TotalContractOrder;
        public decimal OpenInvoiceTotal;
        public decimal TotalInvoice;
        public decimal TotalProfitLoss;
        public decimal projectProfitLossTotal;
        public decimal grossProfitTotal;
        public decimal CIEBTotal;
        public decimal BIECTotal;
    }
    //Task of Schedule
    @AuraEnabled
    public static string getScheduleData(String recordId){
        List<schedulewrapper> resultWrap = new List<schedulewrapper>();
        
        List<String> sIdSet = new List<String>();  
        
        List<buildertek__Schedule__c> s;
       /* if (Schema.sObjectType.buildertek__Schedule__c.fields.Id.isAccessible() && 
            Schema.sObjectType.buildertek__Schedule__c.fields.Name.isAccessible() &&
            Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Project__c.isAccessible() ){*/
           s=[select id,name from buildertek__Schedule__c where buildertek__Project__c=:recordId];
       /*}*/
        MAP<id,buildertek__Schedule__c> scheduleMap = new MAP<id,buildertek__Schedule__c>(s);
        
        for(buildertek__Schedule__c temp :s){
            sIdSet.add(temp.id);
        }
        Date dt=System.today();
        List<buildertek__Project_Task__c> t;
       /* if (Schema.sObjectType.buildertek__Project_Task__c.fields.Id.isAccessible() && 
            Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isAccessible() &&
            Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Finish__c.isAccessible() && 
			Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Schedule__c.isAccessible() &&
            Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Duration__c.isAccessible() && 
			Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Finish__c.isAccessible() &&
            Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Status__c.isAccessible() ) {*/
           t=[select id,name,buildertek__Start__c,buildertek__Finish__c,buildertek__Schedule__c,buildertek__Duration__c from buildertek__Project_Task__c where buildertek__Schedule__c In :sIdSet and buildertek__Finish__c < TODAY and buildertek__Status__c !='Completed'];
        /*}*/
        MAP<id,buildertek__Project_Task__c> taskMap = new MAP<id,buildertek__Project_Task__c>(t);
        
        
        for (Id key : scheduleMap.keySet()) {
            schedulewrapper sw=new schedulewrapper();
            List<buildertek__Project_Task__c> ptRecs = new List<buildertek__Project_Task__c>();
            
            sw.scheduleRec=scheduleMap.get(key);
            for (Id temp : taskMap.keySet()) {
                if(taskMap.get(temp).buildertek__Schedule__c == key){
                    buildertek__Project_Task__c ptRec=new buildertek__Project_Task__c();
                    ptRec=taskMap.get(temp);
                    ptRecs.add(ptRec);
                }
            }
            sw.TaskRecs=ptRecs;
            resultWrap.add(sw);
        }
        
        return JSON.serialize(resultWrap);
    }
    public class schedulewrapper{
        public buildertek__Schedule__c scheduleRec;
        public List<buildertek__Project_Task__c> TaskRecs;
    }
    
    
    
    //bar-chart
    
    @AuraEnabled
    public static String getHCChartData(String recordId)
    {  
        ChartData charData=new ChartData();
        List<buildertek__Project__c>  listPro;
        /*if(Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){*/
         listPro=[SELECT Id,Name FROM buildertek__Project__c WHERE Id = :recordId];
       /*}*/
        
        if(listPro.size()>0){
            List<buildertek__Change_Order__c> openChangeOrder=new List<buildertek__Change_Order__c>();
            /*if(Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Total_Amount__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Total_Amount_Tax__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Status__c.isAccessible()){*/
                openChangeOrder=[select id,name,buildertek__Total_Amount__c,buildertek__Total_Amount_Tax__c from buildertek__Change_Order__c where buildertek__Project__c =:recordId And (buildertek__Status__c = 'Approved' or buildertek__Status__c = 'Pending')];
    		/*}*/
            charData.OpenChangeOrder=openChangeOrder;
            
            List<buildertek__Change_Order__c> approvedChangeOrder=new List<buildertek__Change_Order__c>();
            /*if(Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Total_Amount__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Total_Amount_Tax__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Status__c.isAccessible()){*/
                approvedChangeOrder=[select id,name,buildertek__Total_Amount__c,buildertek__Total_Amount_Tax__c from buildertek__Change_Order__c where buildertek__Project__c =:recordId And buildertek__Status__c = 'Customer Approved'];
    		/*}*/
            charData.ApprovedChangeOrder=approvedChangeOrder;
            
            List<buildertek__Billings__c> openInvoice=new List<buildertek__Billings__c>();
         /*if(Schema.sObjectType.buildertek__Billings__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Billings__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Amount__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Total_Amount_Tax__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Project__c.isAccessible()){*/
                openInvoice=[select id,name,buildertek__Amount__c,buildertek__Total_Amount_Tax__c	 from buildertek__Billings__c where buildertek__Project__c =:recordId And buildertek__Status__c = 'Open'];
    			/*}*/
            charData.OpenInvoice=openInvoice;
        }
        return JSON.serialize(charData);
    }
    
    public class ChartData{
        public List<buildertek__Change_Order__c> OpenChangeOrder;
        public List<buildertek__Change_Order__c> ApprovedChangeOrder;
        public List<buildertek__Billings__c> OpenInvoice;
        
    }
}