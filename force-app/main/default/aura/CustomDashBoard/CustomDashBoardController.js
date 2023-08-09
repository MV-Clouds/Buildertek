({
	doInit : function(component, event, helper) {
        helper.chartHelper(component, helper);
		 helper.fetchContract(component,event,helper);
        helper.fetchSchedule(component,event,helper);
        
	},
    onContractHandler :  function(component,event,helper){
       
        var coverage=[];
        var con=component.get("v.Contract");
        var OpenConCoverage=0;
        var ApproveConCoverage=0;
        var openInvoiceCoverage=0;
        
        var OCC =(parseInt(con.OpenOrderTotal)/parseInt(con.TotalContractOrder));
        if(OCC!=null && OCC != undefined && !isNaN(OCC)){
        OpenConCoverage=OCC;
        }
        
        var ACC = (parseInt(con.ApprovedOrderTotal)/parseInt(con.TotalContractOrder));
        if(ACC != null && ACC != undefined && !isNaN(ACC)){
        	ApproveConCoverage=ACC;    
        }
        
        var OIC = (parseInt(con.OpenInvoiceTotal)/parseInt(con.TotalInvoice));
        if(OIC != null && OIC != undefined && !isNaN(OIC)){
        	openInvoiceCoverage=OIC;    
        }
        
       
        coverage.push(OpenConCoverage);
        coverage.push(ApproveConCoverage);
        coverage.push(openInvoiceCoverage);
        
        var chartSkill = component.find("chartSkill");
        
        for(var i=0; i<chartSkill.length; i++){ 
            if(chartSkill[i].getElement() !=undefined){
            if((chartSkill[i].getElement().childNodes)[0] !=null && (chartSkill[i].getElement().childNodes)[0] != '' && (chartSkill[i].getElement().childNodes)[0] !=undefined){
            (chartSkill[i].getElement().childNodes)[0].style.transform='rotate('+(coverage[i]*180).toFixed(2)+'deg)';
            }
            }
            if(chartSkill[i].getElement() != undefined){
            if(((chartSkill[i].getElement().childNodes)[0].childNodes)[0] !=null && ((chartSkill[i].getElement().childNodes)[0].childNodes)[0] !='' && ((chartSkill[i].getElement().childNodes)[0].childNodes)[0] !=undefined){
                 ((chartSkill[i].getElement().childNodes)[0].childNodes)[0].style.transform='rotate(-'+(coverage[i]*180).toFixed(2)+'deg)'; 
           
                if((coverage[i]*180).toFixed(2)>85){
                    ((chartSkill[i].getElement().childNodes)[0].childNodes)[0].style.marginTop='0';
                 }
            }
           
                console.log('Vallueeeee::: ',(coverage[i]*100).toFixed(2)+'%');
            chartSkill[i].getElement().setAttribute("data-coverage",(coverage[i]*100).toFixed(2)+'%');
            }
        } 
        
    },
    
    toggle: function(cmp, evt) {
        var rows = cmp.get("v.rows");
		var component_target = evt.currentTarget;
        var index = component_target.dataset.index;
        rows[index].expanded = !rows[index].expanded;
        //cmp.set("v.rows", rows);
    },
    onclickRec :function(component,event,helper){
        var component_target = event.currentTarget.parentNode;
        var recId = component_target.dataset.index;
        if(recId!=null&&recId!=undefined&&recId!=''){
            var navEvent = $A.get("e.force:navigateToSObject");
                    navEvent.setParams({
                        recordId: recId,
                        slideDevName: "detail"
                    });
                    navEvent.fire();
        }
    },
})