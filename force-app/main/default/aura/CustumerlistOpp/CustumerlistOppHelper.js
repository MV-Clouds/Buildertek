({
    resetData: function(component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.accountType",'');
        component.set("v.oppStage",'');
        component.set("v.constructionType",'');
        var masterData = component.get("v.wrapDataMaster");
        component.set("v.wrapData",component.get("v.wrapDataMaster"));
        component.set("v.showSpinner",false);
        
        component.set("v.openFilter", false);
    },
    fetchAccountInfo: function( component, event, helper ) {
        component.set("v.showSpinner",true);
        var action;
        if(component.get("v.Searchrecordtype")=="Contact")
        {
        var selectedContactRec = event.getParam("contactByEvent");
        component.set("v.contactRec",selectedContactRec);
         action = component.get("c.fetchcontactsDetails");
        action.setParams({
            contactId: selectedContactRec.Id
        });
        }
        if(component.get("v.Searchrecordtype")=="Account" && component.get("v.showOpp")==true)
        {
        var selectedaccountRec = event.getParam("AccountByEvent");
        component.set("v.AccountRec",selectedaccountRec);
         action = component.get("c.fetchaccountsDetails");
        action.setParams({
            AccountId: selectedaccountRec.Id
        });
        }
        if(component.get("v.Searchrecordtype")=="Account" && component.get("v.showpart")==true)
        {
        var selectedaccountRec = event.getParam("AccountByEvent");
        component.set("v.AccountRec",selectedaccountRec);
         action = component.get("c.fetchpartaccountsDetails");
        action.setParams({
            AccountId: selectedaccountRec.Id
        });
        }
        action.setCallback( this, function( response ) {
            if(response.getState() === 'SUCCESS'){
                component.set("v.wrapDataMaster",response.getReturnValue());
                
                component.set("v.showSpinner",false);
                //helper.downloadExcell(component, event, helper);
            }
            //alert('========13======'+JSON.stringify(component.get("v.wrapData")));
            console.log('===29=='+JSON.stringify(component.get("v.wrapData")));
            var wrap = component.get("v.wrapData");
            //alert('========29======'+JSON.stringify(wrap.oppCntctRoleLst)); 
            
        });
        $A.enqueueAction( action );
    },
    
    downloadExcell: function( component, event, finalListToDownload, tableNum ) {
        
        var csv=this.convertArrayOfObjectsToCSV(component,finalListToDownload, tableNum);
        if(csv==null)
        {
            return ;
        }                        
        var elementLink=document.createElement('a');
        elementLink.href='data:text/csv;charset=utf-8,'+encodeURI(csv);
        elementLink.target='_self';
        elementLink.download='contactData.csv';
        document.body.appendChild(elementLink);
        elementLink.click();
        // $A.get('e.force:refreshView').fire();
        
    },
    convertArrayOfObjectsToCSV : function(component,objRecords, tableNum) {
        var csvStringResult,counter,keys,lineDivider,columnDivider;
        if(objRecords==null || !objRecords.length)
        {
            return null;        
        }
        columnDivider=',';
        lineDivider='\n';
        keys = [];
        if(tableNum === 1 || tableNum === 3){
            keys=['AccountName','AccountType','PartnerAccountRole','PartnerAccountName','OpportunityName','Stage','TotalBuildingSQFT','ConstructionType','Owner','CloseDate','DesignWin','CreatedDate','MarketSegment','City','State','AccountId','OpportunityId'];
            
        }
        if(tableNum === 2){
            keys=['ContactName','AccountContactName','AccountName','AccountType','ContactRole','OpportunityName','Stage','TotalBuildingSQFT','ConstructionType','Owner','CloseDate','DesignWin','CreatedDate','MarketSegment','City','State','Contactaccountid','AccountId','OpportunityId'];
            
        }
        csvStringResult='';
        csvStringResult+=keys.join(columnDivider);
        csvStringResult+=lineDivider;
        for(var i=0;i<objRecords.length;i++)
        {
            counter=0;
            for(var tempKey in keys)
            {
                var skey=keys[tempKey];
                if(counter>0)
                {
                    csvStringResult+=columnDivider;
                }
                // Querying standard related object field
                if(typeof objRecords[i][skey]==='object' && (skey==='Owner' || skey==='Account')){
                    csvStringResult+='"'+objRecords[i][skey].Name+'"';
                    counter ++;
                }
                // Querying custom related object field
                else if(typeof objRecords[i][skey]==='object' &&  skey==='Testobject1__r'){
                    csvStringResult+='"'+objRecords[i][skey].Status__c+'"';
                    counter ++;
                }
                // Querying same object field
                    else{
                        csvStringResult+='"'+objRecords[i][skey]+'"';
                        counter ++;
                    }
                
            }
            csvStringResult+=lineDivider;
            
        }
        
        return csvStringResult
    },
    applyFilters: function(component, event, helper) {
        component.set("v.openFilter", false);
        component.set("v.showSpinner",true);
         var selectedContactRec = event.getParam("contactByEvent");
                var accountType = component.get("v.accountType");
                var opprStage = component.get("v.oppStage");
                var conType = component.get("v.constructionType");
                var wraperData = component.get("v.wrapDataMaster");
                var partneraccountrole= component.get("v.partneraccountrole");
               
        var action;
        
           if(component.get("v.Searchrecordtype")=="Contact")
        {
        var selectedContactRec =  component.get("v.contactRec");
      //  component.set("v.contactRec",selectedContactRec);
         action = component.get("c.filtercontatcsDetails");
            
        action.setParams({
            contactId: selectedContactRec.Id,stage:opprStage,accounttype:accountType,constuiontype:conType
        });
        }
        
          if(component.get("v.Searchrecordtype")=="Account" && component.get("v.showOpp")==true)
        {
              var selectedaccountRec = component.get("v.AccountRec");
         action = component.get("c.filteraccountsDetails");
        action.setParams({
            AccountId: selectedaccountRec.Id,stage:opprStage,accounttype:accountType,constuiontype:conType,partneraccountrole:partneraccountrole
        });
        }
         if(component.get("v.Searchrecordtype")=="Account" && component.get("v.showpart")==true)
        {
              var selectedaccountRec = component.get("v.AccountRec");
         action = component.get("c.filterpartDetails");
        action.setParams({
            AccountId: selectedaccountRec.Id,stage:opprStage,accounttype:accountType,constuiontype:conType,partneraccountrole:partneraccountrole
        });
        }
       
        action.setCallback( this, function( response ) {
            if(response.getState() === 'SUCCESS'){
                component.set("v.wrapDataMaster",response.getReturnValue());
                
                
                var firstTable = wraperData.oppAccLvlRecd;
                var secondTable = wraperData.cntctRleLvlRecd;
                
                var filteredFT = [];
                var filteredST = [];
             /*   for(var r in firstTable){
                    if(accountType !== 'Choose one...' && accountType !== ''){
                        if(firstTable[r].AccountType === accountType){
                            filteredFT.push(firstTable[r]);
                        }
                    }
                    if(opprStage !== 'Choose one...' && opprStage !== ''){
                        if(firstTable[r].Stage === opprStage){
                            filteredFT.push(firstTable[r]);
                        }
                    }
                    if(conType !== 'Choose one...' && conType !== ''){
                        if(firstTable[r].ConstructionType === conType){
                            filteredFT.push(firstTable[r]);
                        }
                    }
                }*/
                //alert('===37====');
               /* for(var r in secondTable){
                    if(accountType !== 'Choose one...' && accountType !== ''){
                        if(secondTable[r].AccountType === accountType){
                            filteredST.push(secondTable[r]);
                        }
                    }
                    if(opprStage !== 'Choose one...' && opprStage !== ''){
                        if(secondTable[r].Stage === opprStage){
                            filteredST.push(secondTable[r]);
                        }
                    }
                    if(conType !== 'Choose one...' && conType !== ''){
                        if(secondTable[r].ConstructionType === conType){
                            filteredST.push(secondTable[r]);
                        }
                    }
                }*/
                wraperData.oppAccLvlRecd = filteredFT;
                wraperData.cntctRleLvlRecd = filteredST;
                component.set("v.wrapData",wraperData);
                component.set("v.showSpinner",false);
            }});
        $A.enqueueAction( action );
        
    },
    sortBy: function(component,helper,field) {
        
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField");
        var records;
        
        if(component.get("v.Searchrecordtype")=="Contact")
        {
           records = component.get("v.wrapDataMaster.cntctRleLvlRecd");
        }
        if(component.get("v.Searchrecordtype")=="Account" && component.get("v.showOpp")==true)
        {
           // alert('233');
         records   = component.get("v.wrapDataMaster.oppAccLvlRecd");
        }
        if(component.get("v.Searchrecordtype")=="Account" && component.get("v.showpart")==true)
        {//alert('233');
         records   = component.get("v.wrapDataMaster.partRleLvlRecd");
        }
        //alert(records);
       // alert(records.lenght);
        if(records!=undefined)
        {
            sortAsc = sortField != field || !sortAsc;
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        }
        
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        
         if(component.get("v.Searchrecordtype")=="Contact")
        {
          component.set("v.wrapDataMaster.cntctRleLvlRecd", records);
        }
        if(component.get("v.Searchrecordtype")=="Account" && component.get("v.showOpp")==true)
        {
          component.set("v.wrapDataMaster.oppAccLvlRecd", records);
        }
        if(component.get("v.Searchrecordtype")=="Account" && component.get("v.showpart")==true)
        {
          component.set("v.wrapDataMaster.partRleLvlRecd", records);  
        }
        
        
        
     //   component.set("v.wrapDataMaster.oppAccLvlRecd", records);
        var startPosn = component.get("v.startPosn");
        var endPosn = component.get("v.endPosn");
        var pageSize = component.get("v.pageSize");
        
        startPosn=0;
        endPosn=pageSize-1;
        component.set("v.startPosn", startPosn);
        component.set("v.endPosn", endPosn);
        
    },
   
})