public class SendLienReleaseBatch implements Database.Batchable<sObject>
{
    private List<String> setIds;
    public SendLienReleaseBatch(List <String> setPOIds) {
        setIds = setPOIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id, Name, buildertek__Vendor__c FROM buildertek__Purchase_Order__c where Id IN: setIds ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<buildertek__Purchase_Order__c> PoList) {
        system.debug('%%%%%%%%%%%%'+PoList[0]);
        Map<string,list<string>> purchaseorderMap = new Map <string,list<string>>();
        list<id> vendorIds = new list<id>();
        String htmlBody = '';
        List<String> cc = new List<String>();
         cc.add('');
        string Emailsubject = '';
        string fileid = '';
        Emailtemplate templateId = [Select Id, Name, folder.name from Emailtemplate where Name =: 'Purchase Order Lien Template']; 
        for(buildertek__Purchase_Order__c purchaserec : PoList){
            vendorIds.add(purchaserec.buildertek__Vendor__c);
        } 
        list<Contact> conlist = [select id,Name,AccountId,buildertek__Primary_Contact__c from Contact where AccountId =: vendorIds AND buildertek__Primary_Contact__c = true];
        for(Contact conrec : conlist){
            if(purchaseorderMap.get(conrec.AccountId) != null){
                list<string> existingconids = purchaseorderMap.get(conrec.AccountId);
                existingconids.add(conrec.id);
                purchaseorderMap.put(conrec.AccountId,existingconids);
            }else{
               list<string> newconids = new list<string>();  
               newconids.add(conrec.id); 
               purchaseorderMap.put(conrec.AccountId,newconids); 
            }
        }
        for(buildertek__Purchase_Order__c purchaserec : PoList){
          list<string> existingconids = purchaseorderMap.get(purchaserec.buildertek__Vendor__c);
           system.debug('hii'+purchaserec.id);
            system.debug(templateId.id);
            system.debug(existingconids);
            system.debug(fileid);
           Emailsubject = 'PurchaseOrder[ref:'+purchaserec.id+']';
            if(existingconids != null){
                PreviewPurchaseOrderLineController.sendPurchaseOrderLineRelease(htmlBody,purchaserec.id,templateId.id,existingconids,cc,Emailsubject,fileid);      
            }
        }
       
    }
    public void finish(Database.BatchableContext BC)
    {
    }
}