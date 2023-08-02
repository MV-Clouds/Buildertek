({    
    Sendmail : function(component) {
        component.set("v.IsSpinner",true);
        //alert('email-------'+email);
        //var Subject=this._e('txtSubject').value;
        //var Message=component.get("v.myMessage");   
        var action=component.get("c.sendEmail");
        //alert('action------'+action);
        action.setParams({
            ids:component.get("v.recordId"),
            mailBody:component.get("v.myMessage"),
            mailSub:component.get("v.sub")
        })
        action.setCallback(this,function(e){
            var res=e.getReturnValue();                
            console.log(res);
            //alert('eeeeeee-------'+e.getState())
            if(e.getState()=='SUCCESS'){    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Email Sent Successfully',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });  
                toastEvent.fire();   
                window.location.reload(true);
                component.set("v.IsSpinner",false);
            }
            else{
                //alert(res);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:res,   //'Invalid email address.',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                //window.location.reload(true);
            }
            component.set("v.IsSpinner",false);
        });
        $A.enqueueAction(action);
        //$A.get('e.force:refreshView').fire();
    },
    getRecordDetails : function(component, event, helper) {
        //alert('In getRecordDetails');
        var action = component.get("c.getSalesOrderDetails");
        //alert('action------------'+action);
        action.setParams
        ({ 
            salesOrderId : component.get("v.recordId"),
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                //alert('State-----------'+state);
                var res=response.getReturnValue();
                console.log({res});
                var validation = false;
                // debugger;
                //alert('res--------'+JSON.stringify(res));
                //alert('Amount----'+res.order.buildertek__Total_Amount_Tax__c); 
                //alert('Accountt-------'+res.order.buildertek__Customer_Account__c);
                if(res.order.buildertek__Project__c != undefined){
                    if(res.order.buildertek__Project__r.buildertek__Customer__c != undefined && res.order.buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c != undefined){
                		component.set("v.Emaillink", res.order.buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c);
                    }
                }

                if(res.order.buildertek__Project__c == undefined){
                    validation = true;
                    $A.get("e.force:closeQuickAction").fire();
                   component.find('notifLib').showNotice({
                       "variant": "error",
                       "header": "Send payment validation!",
                       "message": "Please select Project",
                      
                   });     
                }

                if(res.order.buildertek__Project__r.buildertek__Customer__c == undefined){
                    validation = true;
                     $A.get("e.force:closeQuickAction").fire();
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Send payment validation!",
                        "message": "Please select customer account",
                       
                    });                    
                    
                }else if(res.order.buildertek__Project__c != undefined && res.order.buildertek__Project__r.buildertek__Customer__c != undefined){
                    if(res.order.buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c == undefined){
                        validation = true;
                        $A.get("e.force:closeQuickAction").fire();
                        component.find('notifLib').showNotice({
                            "variant": "error", 
                            "header": "Send payment validation!",
                            "message": "Please provide an email address for this Customer Account",
                            
                        });     
                    }else if(res.order.buildertek__Total_Amount_Tax__c == 0){
                        validation = true;
                         $A.get("e.force:closeQuickAction").fire();
                        component.find('notifLib').showNotice({
                            "variant": "error",
                            "header": "Send payment validation!",
                            "message": "Amount can not be zero(0)",
                           
                        });  
                    }   
                }
                
                             
                
                if(validation==false){
                    component.set("v.SendMailBox", true);
                    //component.set("v.recordContactEmail", res.order.buildertek__Customer_Account__r.buildertek__Email_Address__c);
                    //component.set("v.recordCarrier", res.order.buildertek__Customer_Account__r.Name);
                    component.set("v.myMessage",'Only for testing  '); 
                    component.set("v.sub",'Test Email'); 
                }
                
                
            }
        });
        $A.enqueueAction(action);
    },
    _e:function(ele){
        return document.getElementById(ele);
    },
})