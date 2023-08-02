({ 
    getcurr : function (component, event, helper) {
        var action = component.get("c.getRfqTo");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                   component.set("v.currencycode",response.getReturnValue());
			} 
		});
		$A.enqueueAction(action);		
    },
    getmulticur : function (component, event, helper) {
        var action = component.get("c.getmulticurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                  component.set("v.multicurrency",response.getReturnValue());
               
                //  component.set("v.multicurrency",false);
			} 
		});
		$A.enqueueAction(action);		
    },
     getuser : function (component, event, helper) {
       //  alert("hai");
          var action = component.get("c.currentUserDetailMethod");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result= response.getReturnValue(); 
                console.log({result});
               //  alert('MY.........'+JSON.stringify(result));
                component.set("v.currentUserList", result);
               // alert( 'kkkkkkk'+component.set("v.currentUserList", result));
            }
        });
            $A.enqueueAction(action);
            helper.getvalues(component, event, helper);
     },
    
      getvalues : function (component, event, helper) {
          
        var action1 = component.get("c.customsettings");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var currentuser = component.get("v.currentUserList");
                var results= response.getReturnValue(); 
                if(results[0]['buildertek__RFQListId__c']){
                     component.set("v.listviewName",results[0]['buildertek__RFQListId__c']);
                     component.set("v.selectedListViewName",results[0]['buildertek__RFQListName__c']);
                     component.set('v.Ispinned', true); 
                     component.set('v.Ispin', false); 
                }
                     if(results[0]['buildertek__RFQUser__c'] != currentuser ){
                          component.set("v.listviewName",'All');
                          component.set("v.selectedListViewName",'All');
                     }
                
               
                component.set("v.Vendorlist", results);
            }
        });
 
        $A.enqueueAction(action1);
	
         
     },
    toastMsg : function( strType, strMessage ) {  
        var showToast = $A.get( "e.force:showToast" );   
        showToast.setParams({   
            
            //message : strMessage,  
            //type : strType,  
            //mode : 'sticky'  
            
            title : "Success!",
            message : strMessage,
            type: 'success',
            duration: '1000',
            key: 'info_alt',
            mode: 'pester'
            
        });   
        showToast.fire();
    },
    
    /*  SearchHelper : function(component, event, helper) {
              
        var action = component.get('c.fetchAcc');
         action.setParams({ searchKey : component.get("v.searchKeyword"),
                          });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                alert(state);
                var allValues = response.getReturnValue();
                alert('allValue' + JSON.stringify(allValues));
                console.log("allValues--->>> " + JSON.stringify(allValues));
                //component.set('v.activeSections', allValues.Name);
                component.set('v.RFQVendorLineList', allValues);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error Message: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    },*/
    getrelatedrfqvendorlist : function(component, event, helper){
        component.set("v.loaded", true);
               component.set('v.columns', [
               {label: 'RFQ #', fieldName: 'Id', type: 'url',
               typeAttributes: {
               label: {
               fieldName: 'WhatName'
               },
               target: '_self'
               }
               },
               //{label: 'RFQ', fieldName: 'RFQName', type: 'text'},
               /*{label: 'RFQ', fieldName: 'RFQName', type: 'url',
            typeAttributes: {
            label: {
            fieldName: 'RFQID'
            },
            target: '_self'
            }},*/
               {label: 'RFQ Description', fieldName: 'RFQName', type: 'Text'},
               {label: 'Status', fieldName: 'buildertek__Status__c', type: 'Picklist'},
               /*{label: 'Quote Amount', fieldName: 'buildertek__Quote_Amount__c', type: 'currency'},*/
                   {label: 'Quote Amount', fieldName: 'buildertek__Quote_Amount__c', type: 'currency',
                    typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
                    cellAttributes: {
                        class: 'slds-grid slds-grid_align-spread',
                    },
                   },
               {label: 'Open RFI', fieldName: 'buildertek__Open_RFI__c', type: 'Number'},
               
           ]);   
            var action = component.get("c.getvendorRelatedList");
            action.setParams({
            recId : component.get("v.rfqrecordId")
            })
            action.setCallback(this, function(data){
            var result = data.getReturnValue();
                   console.log({result});
                   console.log('GET VENDOER LIST');
                   for ( var i = 0; i < result.length; i++ ) {
                   var row = result[i];
                             // if ( row.buildertek__RFQ__c) {
                             row.RFQName = row.buildertek__RFQ__r.Name;
                             //row.RFQDescription = row.buildertek__RFQ__r.buildertek__Description__c;
                             //  row.RFQName = '/vendor/s/rfq-to-vendor/' + row.buildertek__RFQ__c;
                             //   row.RFQID = row.buildertek__RFQ__r.Name;
                             //}
                             // alert('row.buildertek__Quote_Amount__c'+row.buildertek__Quote_Amount__c);
                             //if ( row.buildertek__Quote_Amount__c) {
                             
                             // row.QuoteAmount = row.buildertek__Quote_Amount__c;
                             //}
                             var rfqauto =  row.buildertek__RFQ__r.buildertek__Auto_Number__c.split("-");
        row.WhatName = 'RFQ' +'-'+ rfqauto[1]; 
        if(component.get("v.multicurrency") == true){
           row.CurrencyIso = row.CurrencyIsoCode;
        }else{
            row.CurrencyIso = component.get("v.currencycode");  
        }
        row.Id = '/vendor/s/rfq-to-vendor/' + row.Id;
        
        
    }
    component.set("v.RFQVendorLineList",result);
    
    component.set("v.loaded", false);
    });
    $A.enqueueAction(action);
    },
        getRFQListViews : function(component, event, helper){
            debugger;
           /* var action = component.get("c.fetchListViews");
           
            action.setParams({
            "strObjName":"buildertek__RFQ_To_Vendor__c"
            })
            action.setCallback(this,function(response){
                
                var result = response.getReturnValue();
        
                if(response.getState() == 'SUCCESS'){
                    
                    var listViewMap = [];
                    var idx = 0;
                    for(var key in result){
                        
                       // alert(result[key]);
                       // alert('idx'+idx);
                        if(idx == 0 && result[key] == 'All'){
                            helper.getrelatedrfqvendorlist(component, event, helper);
                        }else if(result[key] != 'All' && idx == 0  ){
                           // alert("hhhhhhhhhhhhhhhh");
                            var action = component.get("c.getListViewQuery");
                            action.setParams({
                                "listViewId": key,
                                "objName" : "buildertek__RFQ_To_Vendor__c"
                                
                            })
                            action.setCallback(this,function(response){
                                //console.log(JSON.stringify(response.getReturnValue()));
                                
                                var result = response.getReturnValue().RFQVendorList;
                                
                                if(response.getState() == 'SUCCESS'){
                                    if(response.getReturnValue().Issuccess == true){
                                        //console.log('!!!!!'+JSON.stringify(result));
                                        
                                        for ( var i = 0; i < result.length; i++ ) {
                                            var row = result[i];
                                            
                                            // if ( row.buildertek__RFQ__c) {
                                            row.RFQName = row.buildertek__RFQ__r.Name;
                                            
                                            var rfqauto =  row.buildertek__RFQ__r.buildertek__Auto_Number__c.split("-");
                                            row.WhatName = 'RFQ ' +' - '+ rfqauto[1]; 
                                            row.Id = '/vendor/s/rfq-to-vendor/' + row.Id;
                                        }
                                        
                                        
                                        component.set("v.RFQVendorLineList",result);
                                    }else{
                                        console.log(response.getReturnValue().message);
                                    }
                                    
                                }else{
                                    //alert('ERROR');
                                    //alert(JSON.stringify(response.getError()));
                                }
                                
                                
                                
                            });
                            $A.enqueueAction(action);
                        }
                        
                        idx++;
                        listViewMap.push({key: key, value: result[key]});
                        
                        
                    }
                    component.set("v.listViewMap", listViewMap);
         			//component.set("v.Vendorlist", Vendorlist);
        
                    //alert(component.get("v.listViewMap"));
                }else{
                    
                }
                
            });
            $A.enqueueAction(action);*/
               var action = component.get("c.fetchListViews");
           
            action.setParams({
            "strObjName":"buildertek__RFQ_To_Vendor__c"
            })
            action.setCallback(this,function(response){
                
                var result = response.getReturnValue();
                console.log({result});
        //alert('&&&'+response.getState());
                if(response.getState() == 'SUCCESS'){
                    
                    var listViewMap = [];
                    var idx = 0;
                    for(var key in result){
                       // alert('key....'+key);
                       // alert('idx....'+idx);
                     //  alert('listviewName....hhhh'+component.get("v.listviewName"));
                      var listview = component.get("v.listviewName");
                        var listviewname = component.get("v.selectedListViewName");
                       // alert(listviewname);
                        if(component.get("v.listviewName") && idx==0 && listviewname != 'All' ){
                          //  alert('listviewName....'+component.get("v.listviewName"));
                            var action = component.get("c.getListViewQuery");
                            action.setParams({
                                "listViewId": component.get("v.listviewName"),
                                "objName" : "buildertek__RFQ_To_Vendor__c"
                                
                            })
                            action.setCallback(this,function(response){
                                //console.log(JSON.stringify(response.getReturnValue()));
                                
                                var result = response.getReturnValue().RFQVendorList;
                                console.log('getListViewQuery');
                                console.log({result});
                                if(response.getState() == 'SUCCESS'){
                                    if(response.getReturnValue().Issuccess == true){
                                        //console.log('!!!!!'+JSON.stringify(result));
                                        
                                        for ( var i = 0; i < result.length; i++ ) {
                                            var row = result[i];
                                            
                                            // if ( row.buildertek__RFQ__c) {
                                            row.RFQName = row.buildertek__RFQ__r.Name;
                                            
                                            var rfqauto =  row.buildertek__RFQ__r.buildertek__Auto_Number__c.split("-");
                                            row.WhatName = 'RFQ ' +' - '+ rfqauto[1]; 
                                            row.Id = '/vendor/s/rfq-to-vendor/' + row.Id;
                                            
                                        }
                                        
                                        
                                        component.set("v.RFQVendorLineList",result);
                                        //alert('HI'+component.get("v.RFQVendorLineList").length);
                                    }else{
                                        console.log(response.getReturnValue().message);
                                    }
                                    
                                }else{
                                    //alert('ERROR');
                                    //alert(JSON.stringify(response.getError()));
                                }
                                
                            });
                            $A.enqueueAction(action);
                             }
                        
                        else if( listviewname == 'All' && idx==0){
                           //  alert("hai");
                            helper.getrelatedrfqvendorlist(component, event, helper);
                        }
                                 else if(idx == 0 && result[key] == 'All'){
                          //  alert("hai");
                            helper.getrelatedrfqvendorlist(component, event, helper);
                            
                        }else if(result[key] != 'All' && idx == 0  ){
                            var action = component.get("c.getListViewQuery");
                            action.setParams({
                                "listViewId": key,
                                "objName" : "buildertek__RFQ_To_Vendor__c"
                                
                            })
                            action.setCallback(this,function(response){
                                //console.log(JSON.stringify(response.getReturnValue()));
                                
                                var result = response.getReturnValue().RFQVendorList;
                                console.log('vendor list');
                                console.log({result});
                                if(response.getState() == 'SUCCESS'){
                                    if(response.getReturnValue().Issuccess == true){
                                        //console.log('!!!!!'+JSON.stringify(result));
                                        
                                        for ( var i = 0; i < result.length; i++ ) {
                                            var row = result[i];
                                            
                                            // if ( row.buildertek__RFQ__c) {
                                            row.RFQName = row.buildertek__RFQ__r.Name;
                                            
                                            var rfqauto =  row.buildertek__RFQ__r.buildertek__Auto_Number__c.split("-");
                                            row.WhatName = 'RFQ ' +' - '+ rfqauto[1]; 
                                            row.Id = '/vendor/s/rfq-to-vendor/' + row.Id;
                                           
                                        }
                                        
                                        
                                        component.set("v.RFQVendorLineList",result);
                                         //alert('HI'+component.get("v.RFQVendorLineList").length);
                                    }else{
                                        console.log(response.getReturnValue().message);
                                    }
                                    
                                }else{
                                    //alert('ERROR');
                                    //alert(JSON.stringify(response.getError()));
                                }
                                
                            });
                            $A.enqueueAction(action);
                        }
                        
                        idx++;
                        listViewMap.push({key: key, value: result[key]});
                        
                    }
                    component.set("v.listViewMap", listViewMap);
                    //alert(component.get("v.listViewMap"));
                }else{
                    
                }
                
            });
            $A.enqueueAction(action);
        },
            

    
})