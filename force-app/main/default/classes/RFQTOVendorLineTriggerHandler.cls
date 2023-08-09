public class RFQTOVendorLineTriggerHandler {
    
    public void beforeInsert(list<buildertek__RFQ_Vendor_Item__c> newvendoritemslist){
       system.debug('New Vendor List --------> '+newvendoritemslist);
          String portalCode = '';
        string userName = userInfo.getUserId();
        list<Network> netRec = [SELECT Id FROM Network where Status = 'Live'];
        if(netRec.size() > 0){
            string strQry1 = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
            list<User> userRec = Database.query(strQry1);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
                system.debug(portalCode);
            }
            system.debug(userRec[0]);
            for(buildertek__RFQ_Vendor_Item__c vendor : newvendoritemslist){ 
                if(portalCode == 'false'){
                    system.debug('helo');
                    vendor.buildertek__CreateVendor__c = true;
                }
                else{
                    vendor.buildertek__CreateVendor__c = false;
                }
                system.debug('Updated Vendor List --------> '+newvendoritemslist);
            }
        }
    }
    public void beforeUpdate(list<buildertek__RFQ_Vendor_Item__c> vendoritemslist){
        list<Id> vendorIds = new list<Id>();
        for(buildertek__RFQ_Vendor_Item__c vendorRec : vendoritemslist){
            vendorIds.add(vendorRec.buildertek__Vendor__c);
        }
        list<buildertek__RFQ_To_Vendor__c> rfqlist = [select id,Name,buildertek__Status__c from buildertek__RFQ_To_Vendor__c where Id IN: vendorIds]; 
        for(buildertek__RFQ_To_Vendor__c rfqRec : rfqlist){
            for(buildertek__RFQ_Vendor_Item__c vendorRec : vendoritemslist){
                if(vendorRec.buildertek__Vendor__c == rfqRec.id){
                    system.debug('%%%'+rfqRec.buildertek__Status__c);
                    if(rfqRec.buildertek__Status__c == 'Quote Submitted'){
                        vendorRec.buildertek__Vendor_Estimated_Work_Days__c = vendorRec.buildertek__Estimated_Work_Days__c;
                        vendorRec.buildertek__Note__c = vendorRec.buildertek__Vendor_Note__c;
                        vendorRec.buildertek__Vendor_Unit_Price__c = vendorRec.buildertek__Unit_Price__c;
                        vendorRec.buildertek__Vendor_Quantity__c = vendorRec.buildertek__Quantity__c; 
                    }
                }
            }
        }
    }
    
 /*    public void afterUpdate(list<buildertek__RFQ_Vendor_Item__c> vendoritemslist){
     
     List<Id> rfqVendorIds = new List<Id>();
for(buildertek__RFQ_Vendor_Item__c a : vendoritemslist){
  
  rfqVendorIds.add(a.Id);
  

}

List<buildertek__RFQ_Vendor_Item__c> rfqVendorItemRec = new List<buildertek__RFQ_Vendor_Item__c>();
if(rfqVendorIds.size() > 0){
 rfqVendorItemRec = [select id,buildertek__Vendor__r.buildertek__Status__c,buildertek__RFQ_Item__r.buildertek__Pricing_Request_Line_Detail__c,buildertek__Unit_Price__c from buildertek__RFQ_Vendor_Item__c where Id IN :rfqVendorIds AND buildertek__Vendor__r.buildertek__Status__c = 'Awarded' AND buildertek__RFQ_Item__r.buildertek__Pricing_Request_Line_Detail__c != null];

}

Map<buildertek__RFQ_Vendor_Item__c,buildertek__Pricing_Request_Line_Details__c> maplist = new Map<buildertek__RFQ_Vendor_Item__c,buildertek__Pricing_Request_Line_Details__c>();
for(buildertek__RFQ_Vendor_Item__c b : rfqVendorItemRec){
 
 maplist.put(b,[select id,buildertek__Cost__c from buildertek__Pricing_Request_Line_Details__c where id =: b.buildertek__RFQ_Item__r.buildertek__Pricing_Request_Line_Detail__c]);

}
  List<buildertek__Pricing_Request_Line_Details__c> prldList = new   List<buildertek__Pricing_Request_Line_Details__c>();
if(maplist.size() > 0){
  
  for(buildertek__RFQ_Vendor_Item__c rvItem : maplist.keySet()){
   buildertek__Pricing_Request_Line_Details__c prld = new buildertek__Pricing_Request_Line_Details__c();
   prld.id =     maplist.get(rvItem).id;
   prld.buildertek__Cost__c = rvItem.buildertek__Unit_Price__c;
   prldList.add(prld);
  
  }

}

if(prldList.size() > 0){
  update prldList;
}
     
     
     } */

}