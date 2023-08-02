public with sharing class SendChangeOrderPDF {

    /**This is the list which will be passed to Visualforce Page and in turn passed to Flow from Visualforce**/
    public List <Change_Order__c > LstSelectedCases {
        get;
        set;
    }
    public  List < Id > casesSelectedIds{
        get;
        set;
    }
     public  List < Id > AllIds{
        get;
        set;
    }
    public String caseids{
        set;get;
    }
    public String parentId{
        set;get;
    }
     public String app{
        set;get;
    }
    public SendChangeOrderPDF(ApexPages.StandardSetController listcontroller) {
      System.debug('Selected Ids : '+listcontroller.getSelected());
        casesSelectedIds = new List < Id > ();
        LstSelectedCases = new List <Change_Order__c >();
         AllIds =  new List < Id > ();
        
        for (Change_Order__c c: (Change_Order__c[]) listcontroller.getSelected()) {
            casesSelectedIds.add(c.id);
        }
        List<Change_Order__c> listOfCOs = [select id,buildertek__Status__c from Change_Order__c where Id in :casesSelectedIds AND buildertek__Status__c = 'Customer Approved'];
        if(listOfCOs != null){
        for(buildertek__Change_Order__c e : listOfCOs){
            System.debug('Id of Approved : '+e.Id);
            AllIds.add(e.id);
        }  
        } 
         System.debug('Condition success : '+AllIds);
        if(casesSelectedIds.size() > 0){
        caseids = JSON.serialize(casesSelectedIds);
               parentId = apexpages.currentpage().getparameters().get('id');
            if(AllIds != null){
            if(casesSelectedIds.size() == AllIds.size()){
                System.debug('Condition success');
            }
            else{
                 System.debug('Condition error');
                app = 'noApp';
            } 
            } 
        }
        else{
            caseids = 'error';
            parentId = apexpages.currentpage().getparameters().get('id');
            System.debug('Id : '+apexpages.currentpage().getparameters().get('id'));
        } 
       
        
          System.debug('Change Order Ids : '+casesSelectedIds);
        System.debug('Error : '+caseids);
   JSON.serialize(casesSelectedIds);
      //  System.debug('Change Order Ids : '+casesSelectedIds[0]);
        /**Querying on the Selected records and fetching fields which are required in Flow **/
      /*  LstSelectedCases = [select Id from Change_Order__c where id in: casesSelectedIds];
        system.debug('LstSelectedCases...........'+LstSelectedCases);
        JSON.serialize(LstSelectedCases); */
    }

    public void callCancel() {
        System.debug('Inside callCancel');
        ApexPages.StandardController sc = new ApexPages.StandardController(new Change_Order__c());
        sc.cancel();

        
    }
}