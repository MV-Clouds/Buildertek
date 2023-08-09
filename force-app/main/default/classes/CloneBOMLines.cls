public with sharing class CloneBOMLines {
    @InvocableMethod
    public static void cloneBOMLine(List<List<String>> CloneIdCollectid){
    try{
        System.debug('CloneIdCollectid-->'+CloneIdCollectid);
        String newBOMId ;
        Set<String> BOMLineSet = new Set<String>();
        Schema.SObjectType TOObject = Schema.buildertek__Project_Selection_Sheet_Takeoff__c.getSObjectType();
        System.debug('TOObject-->'+TOObject);
        for(List<String> slist : CloneIdCollectid){
          for(String s : slist){
            Schema.SObjectType record = Id.valueOf(s).getsobjecttype();
            if(TOObject == record){
              newBOMId = s;
            }else{
              BOMLineSet.add(s);
            }
          }
        }

        System.debug('BOMLineSet-->'+BOMLineSet);
        System.debug('newBOMId-->'+newBOMId);

        List<buildertek__Select_Sheet__c> cloneBOMLineList = new List<buildertek__Select_Sheet__c>();
        List<buildertek__Select_Sheet__c> bccList = [SELECT buildertek__Active__c,Name,
                                                        buildertek__Allowance__c,buildertek__Selection_Sheet_Takeoff__c,buildertek__BT_Price_Book__c,buildertek__Build_Phase__c,
                                                        buildertek__Category__c,buildertek__Description__c,buildertek__BL_DISCOUNT__c,buildertek__BL_DISCOUNT_AMOUNT__c,buildertek__Instructions__c,
                                                        buildertek__BL_LIST_PRICE_F__c,buildertek__BL_LIST_PRICE__c,buildertek__Location__c,buildertek__Location_Picklist__c,buildertek__Locked__c,
                                                        buildertek__Build_Reference_1__c,buildertek__Base_Location__c,buildertek__Location_Detailed_Area__c,buildertek__Location_Detail_Reference_1__c,buildertek__Install_Location__c,buildertek__Install_Location_Reference__c,
                                                        buildertek__BL_MARKUP__c,buildertek__BL_MARKUP_AMOUNT__c,buildertek__Option__c,buildertek__Option_Details__c,buildertek__Plan__c,buildertek__Product__c,
                                                        buildertek__Product_Type__c,buildertek__Project__c,buildertek__Purchase_Order__c,buildertek__Quantity__c,buildertek__Standard__c,buildertek__Takeoff_Line__c,
                                                        buildertek__Trade_Type__c,buildertek__Type__c,buildertek__BL_UNIT_COST__c,buildertek__Upgrade_Price__c,buildertek__Vendor__c 
                                                        FROM buildertek__Select_Sheet__c WHERE Id IN: BOMLineSet];

        System.debug('bccList-->'+bccList);
        System.debug('bccList-->'+bccList.size());
        for(buildertek__Select_Sheet__c bomline : bccList){
            buildertek__Select_Sheet__c cloneBOMline = bomline.clone(false, false, false, false);
            cloneBOMline.buildertek__Selection_Sheet_Takeoff__c = newBOMId;
            clonebomlineList.add(cloneBOMline);
        }

        System.debug('clonebomlineList-->'+clonebomlineList);
        System.debug('clonebomlineList-->'+clonebomlineList.size());
        
        if(!clonebomlineList.isEmpty()){
          insert clonebomlineList;
        } 
    }catch(Exception e){
        System.debug('Exception-->'+e);
        System.debug('Exception Line Number -->'+e.getLineNumber());
        System.debug('Exception Cause -->'+e.getCause());
    }
  }
}