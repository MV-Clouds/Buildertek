public class CreateCOFromPRController {

      @AuraEnabled
    public static string getprrec(Id recordId){
        buildertek__Pricing_Request__c pricingRec=  [SELECT Id, Name, buildertek__Status__c, buildertek__Information__c, buildertek__Quoted_By__c,buildertek__Quoted_By__r.Email, buildertek__Selections_Manager__c, buildertek__Customer__c, buildertek__Price__c, buildertek__Project__c,
                                                     buildertek__Date_Pricing_Submitted__c, buildertek__Date_Pricing_Returned__c, buildertek__Date_Pricing_Completed__c,
                                                     buildertek__Change_Order__c FROM buildertek__Pricing_Request__c where Id =: recordId]; 
        list<buildertek__Pricing_Request_Line__c> prlineRecs=  [SELECT Id,Name, buildertek__Description__c, buildertek__Status__c, buildertek__Vendor__c, buildertek__Pricing_Request__c, buildertek__Notes__c, buildertek__Reject_Reason__c, buildertek__Type__c,
                                                                buildertek__Pricing_Request__r.Name,buildertek__Pricing_Request__r.buildertek__Project__c,buildertek__Change_Order__c,
                                                                buildertek__RFQ__c, buildertek__Cost__c, buildertek__Markup__c, buildertek__Price__c,buildertek__New_Price__c FROM buildertek__Pricing_Request_Line__c where buildertek__Pricing_Request__c =: pricingRec.Id and 
                                                               buildertek__Status__c = 'Accepted'];
                                                               
        buildertek__Change_Order__c changeorderRec = new buildertek__Change_Order__c();
        changeorderRec.Name = pricingRec.Name;
        // changeorderRec.buildertek__Project__c = prline.buildertek__Pricing_Request__r.buildertek__Project__c;
        changeorderRec.buildertek__Date_Created__c = System.today();
        /*   changeorderRec.buildertek__Vendor__c = prline.buildertek__Vendor__c;
        changeorderRec.buildertek__Markup__c = prline.buildertek__Markup__c;
        changeorderRec.buildertek__Pricing_Request_Line__c = prline.id;
        changeorderRec.buildertek__Pricing_Request__c = prline.buildertek__Pricing_Request__c;    */
        changeorderRec.buildertek__Status__c = 'Pending';
        changeorderRec.buildertek__Pricing_Request__c = pricingRec.Id;
        changeorderRec.buildertek__Project__c = pricingRec.buildertek__Project__c;
        insert  changeorderRec;   
        pricingRec.buildertek__Change_Order__c = changeorderRec.Id;
        
        System.debug('prlineRecs-->>'+prlineRecs);
        if(prlineRecs.size()>0){
            System.debug('--In If--');
            update pricingRec;
            list<buildertek__Change_Order_Item__c> chageordelist= new list<buildertek__Change_Order_Item__c>();
            for(buildertek__Pricing_Request_Line__c prline : prlineRecs){
                buildertek__Change_Order_Item__c changeorderLineRec = new buildertek__Change_Order_Item__c();
                changeorderLineRec.Name = prline.Name;
                changeorderLineRec.buildertek__Change_Order__c = changeorderRec.Id;
                changeorderLineRec.buildertek__Description__c = prline.buildertek__Description__c;
                changeorderLineRec.buildertek__Item_Name__c = prline.buildertek__Description__c;
                changeorderLineRec.buildertek__Markup__c = prline.buildertek__Markup__c;
                //  changeorderLineRec.buildertek__Product__c = prline.
                changeorderLineRec.buildertek__Quantity__c = 1;
                changeorderLineRec.buildertek__Unit_Price__c = prline.buildertek__New_Price__c;
                changeorderLineRec.buildertek__Vendor__c = prline.buildertek__Vendor__c;
                chageordelist.add(changeorderLineRec);
            }                   
            insert chageordelist;
            System.debug('Insert Successfully');
            return 'success';
        }
        else{
            system.debug('Error');
            return 'error';
        }
    }
}