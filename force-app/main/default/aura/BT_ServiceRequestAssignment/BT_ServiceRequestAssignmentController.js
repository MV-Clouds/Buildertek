({	
    showSpinner : function(component, event, helper) {
    },
    hideSpinner : function(component, event, helper) {
    },
    scriptsLoaded : function(component, event, helper) {
        $(function() {
            $( "ul.droptrue" ).sortable({
                connectWith: "ul",
                dropOnEmpty: true
            });
            $( "ul.dropfalse" ).sortable({
                connectWith: "ul",
                dropOnEmpty: true
            });
            $( "ul.dropfalse" ).sortable({
                receive: function(event, ui) {
                    //Run this code whenever an item is dragged and dropped into this list 
                    var itemText= ui.item.attr('id');
                    alert(itemText);
                    alert(ui.item.parent().parent().attr('id'));
                    ui.item.css('width','auto');
                    //alert(itemText+ui.item.parent().parent().attr('id'));
                    dupedetector.TaskAssignmentDashboardController.assignTaskToContact(itemText,ui.item.parent().parent().attr('id'),function(result,event){
                        $("#alert").text(result);
                        $("#alert").slideToggle("slow");
                        $("#alert").center();
                        setTimeout(function(){
                            $("#alert").slideToggle("slow");
                        },2000);
                        //                           alert(result);
                    });
                }
            });
            
            $( "ul.droptrue" ).sortable({
                receive: function(event, ui) {
                    //Run this code whenever an item is dragged and dropped into this list 
                    var itemText= ui.item.attr('id');
                    alert(itemText);
                    ui.item.css('width','auto');
                    //alert(itemText);
                    dupedetector.TaskAssignmentDashboardController.unAssignTaskToContact(itemText,function(result,event){
                        $("#alert").text(result);
                        //$("#alert").fadeIn();
                        
                        
                        
                        $("#alert").slideToggle("slow");
                        $("#alert").center();
                        
                        
                        
                        setTimeout(function(){
                            $("#alert").slideToggle("slow");
                        },2000);
                    });
                }
            });
        });
        
        jQuery.fn.center = function () {
            this.css("position","absolute");
            this.css("top", ( $(window).height() - this.height() ) / 2+$(window).scrollTop() + "px");
            this.css("left", ( (($(window).width() - this.width() ) / 2+$(window).scrollLeft())) + "px");
            return this;
        }
    },
    initialize : function(component, event, helper) {
        helper.getSR(component, event, helper);
    },
    
    createNewServiceRecord : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "buildertek__Service_Request__c"
        });
        createRecordEvent.fire();
    }
})